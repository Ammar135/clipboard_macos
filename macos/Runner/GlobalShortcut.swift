import ApplicationServices
import Cocoa
import FlutterMacOS

protocol GlobalShortcutDelegate: AnyObject {
    func globalShortcutDidPress()
}

class GlobalShortcut {
    weak var delegate: GlobalShortcutDelegate?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var eventSink: FlutterEventSink?
    private(set) var isRegistered = false

    static var isAccessibilityGranted: Bool {
        AXIsProcessTrusted()
    }

    static func requestAccessibility(prompt: Bool = true) -> Bool {
        if AXIsProcessTrusted() {
            return true
        }

        if prompt {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            return AXIsProcessTrustedWithOptions(options)
        }

        return false
    }

    static func openAccessibilitySettings() {
        let urls = [
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility",
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
        ]

        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            if NSWorkspace.shared.open(url) {
                return
            }
        }
    }

    static var appBundlePath: String {
        Bundle.main.bundlePath
    }

    func setEventSink(_ sink: FlutterEventSink?) {
        self.eventSink = sink
    }

    @discardableResult
    func register() -> Bool {
        unregister()

        guard Self.isAccessibilityGranted else {
            NSLog("GlobalShortcut: accessibility permission not granted")
            isRegistered = false
            return false
        }

        let eventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.tapDisabledByTimeout.rawValue) |
            (1 << CGEventType.tapDisabledByUserInput.rawValue)

        let callback: CGEventTapCallBack = { (_, type, event, refcon) -> Unmanaged<CGEvent>? in
            guard let refcon = refcon else {
                return Unmanaged.passUnretained(event)
            }

            let shortcut = Unmanaged<GlobalShortcut>.fromOpaque(refcon).takeUnretainedValue()

            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                shortcut.reenableTap()
                return Unmanaged.passUnretained(event)
            }

            guard type == .keyDown else {
                return Unmanaged.passUnretained(event)
            }

            let flags = event.flags
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let activeModifiers = flags.intersection([
                .maskCommand,
                .maskShift,
                .maskAlternate,
                .maskControl,
            ])

            if activeModifiers == [.maskCommand, .maskShift] && keyCode == 9 {
                shortcut.handleShortcutPressed()
                return nil
            }

            return Unmanaged.passUnretained(event)
        }

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        eventTap = CGEvent.tapCreate(
            tap: .cgAnnotatedSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: selfPointer
        )

        if eventTap == nil {
            eventTap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: CGEventMask(eventMask),
                callback: callback,
                userInfo: selfPointer
            )
        }

        guard let tap = eventTap else {
            NSLog("GlobalShortcut: failed to create event tap")
            isRegistered = false
            return false
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        guard let source = runLoopSource else {
            NSLog("GlobalShortcut: failed to create run loop source")
            isRegistered = false
            return false
        }

        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isRegistered = true
        NSLog("GlobalShortcut: registered successfully")
        return true
    }

    func unregister() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        isRegistered = false
    }

    private func reenableTap() {
        guard let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: true)
        NSLog("GlobalShortcut: re-enabled event tap")
    }

    private func handleShortcutPressed() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.delegate?.globalShortcutDidPress()

            let event: [String: Any] = [
                "event": "shortcut_pressed",
            ]
            self.eventSink?(event)
        }
    }
}
