import ApplicationServices
import Carbon
import Cocoa
import FlutterMacOS

protocol GlobalShortcutDelegate: AnyObject {
    func globalShortcutDidPress()
}

class GlobalShortcut {
    private static let carbonSignature: OSType = 0x43424350 // "CBCP"
    private static let carbonHotKeyId: UInt32 = 1
    private static weak var activeInstance: GlobalShortcut?

    weak var delegate: GlobalShortcutDelegate?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var eventSink: FlutterEventSink?
    private var carbonHotKeyRef: EventHotKeyRef?
    private var carbonEventHandler: EventHandlerRef?

    private(set) var isEventTapRegistered = false
    private(set) var isCarbonRegistered = false

    var isShortcutActive: Bool {
        isEventTapRegistered || isCarbonRegistered
    }

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

    static var executablePath: String {
        Bundle.main.executablePath ?? "unknown"
    }

    func setEventSink(_ sink: FlutterEventSink?) {
        self.eventSink = sink
    }

    @discardableResult
    func registerAll() -> Bool {
        unregister()
        Self.activeInstance = self

        let carbonOk = registerCarbonHotKey()
        let eventTapOk = registerEventTapIfAllowed()

        NSLog(
            "GlobalShortcut: carbon=%@ eventTap=%@ accessibility=%@",
            carbonOk ? "yes" : "no",
            eventTapOk ? "yes" : "no",
            Self.isAccessibilityGranted ? "yes" : "no"
        )

        return isShortcutActive
    }

    @discardableResult
    private func registerCarbonHotKey() -> Bool {
        unregisterCarbonHotKey()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, _ -> OSStatus in
                guard let event = event else {
                    return OSStatus(-50)
                }

                var hotKeyID = EventHotKeyID()
                let parameterStatus = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard parameterStatus == noErr else { return parameterStatus }
                guard hotKeyID.signature == GlobalShortcut.carbonSignature,
                      hotKeyID.id == GlobalShortcut.carbonHotKeyId else {
                    return noErr
                }

                DispatchQueue.main.async {
                    GlobalShortcut.activeInstance?.handleShortcutPressed()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &carbonEventHandler
        )

        guard installStatus == noErr else {
            NSLog("GlobalShortcut: failed to install Carbon handler (%d)", installStatus)
            return false
        }

        let hotKeyID = EventHotKeyID(
            signature: Self.carbonSignature,
            id: Self.carbonHotKeyId
        )
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_V),
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &carbonHotKeyRef
        )

        isCarbonRegistered = registerStatus == noErr
        if !isCarbonRegistered {
            NSLog("GlobalShortcut: failed to register Carbon hotkey (%d)", registerStatus)
        }
        return isCarbonRegistered
    }

    @discardableResult
    private func registerEventTapIfAllowed() -> Bool {
        guard Self.isAccessibilityGranted else {
            isEventTapRegistered = false
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
            isEventTapRegistered = false
            return false
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        guard let source = runLoopSource else {
            isEventTapRegistered = false
            return false
        }

        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isEventTapRegistered = true
        return true
    }

    func unregister() {
        unregisterCarbonHotKey()
        unregisterEventTap()
        if Self.activeInstance === self {
            Self.activeInstance = nil
        }
    }

    private func unregisterCarbonHotKey() {
        if let ref = carbonHotKeyRef {
            UnregisterEventHotKey(ref)
            carbonHotKeyRef = nil
        }
        if let handler = carbonEventHandler {
            RemoveEventHandler(handler)
            carbonEventHandler = nil
        }
        isCarbonRegistered = false
    }

    private func unregisterEventTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        isEventTapRegistered = false
    }

    private func reenableTap() {
        guard let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func handleShortcutPressed() {
        delegate?.globalShortcutDidPress()

        let event: [String: Any] = [
            "event": "shortcut_pressed",
        ]
        eventSink?(event)
    }
}
