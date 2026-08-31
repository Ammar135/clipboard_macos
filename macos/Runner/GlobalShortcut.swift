import Cocoa
import FlutterMacOS

class GlobalShortcut {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var eventSink: FlutterEventSink?
    
    func setEventSink(_ sink: FlutterEventSink?) {
        self.eventSink = sink
    }
    
    func register() {
        // We want to capture Cmd + Shift + V (KeyCode 9 is 'v')
        // We'll listen to keyDown events
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        // This closure is called when an event is intercepted
        let callback: CGEventTapCallBack = { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
            guard type == .keyDown else { return Unmanaged.passUnretained(event) }
            
            let flags = event.flags
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            
            // Cmd (command) + Shift + V (keycode 9)
            let isCommand = flags.contains(.maskCommand)
            let isShift = flags.contains(.maskShift)
            
            if isCommand && isShift && keyCode == 9 {
                // We matched the shortcut!
                // Get the instance back from the raw pointer
                if let refcon = refcon {
                    let shortcutInstance = Unmanaged<GlobalShortcut>.fromOpaque(refcon).takeUnretainedValue()
                    shortcutInstance.notifyFlutter()
                }
                
                // Return nil to consume the event so it doesn't paste in the active app
                return nil
            }
            
            return Unmanaged.passUnretained(event)
        }
        
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: selfPointer
        )
        
        if let tap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            if let source = runLoopSource {
                CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
                CGEvent.tapEnable(tap: tap, enable: true)
                print("Global shortcut registered successfully.")
            }
        } else {
            print("Failed to register global shortcut. Accessibility permissions might be missing.")
        }
    }
    
    func unregister() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
        }
        eventTap = nil
        runLoopSource = nil
    }
    
    private func notifyFlutter() {
        // Must dispatch back to main thread for Flutter EventSink
        DispatchQueue.main.async { [weak self] in
            let event: [String: Any] = [
                "event": "shortcut_pressed"
            ]
            self?.eventSink?(event)
        }
    }
}
