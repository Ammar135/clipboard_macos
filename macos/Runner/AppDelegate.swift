import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate, StatusBarDelegate, GlobalShortcutDelegate {
  private var statusBarController: StatusBarController?
  private var clipboardMonitor = ClipboardMonitor()
  private var globalShortcut = GlobalShortcut()
  private let channels = PlatformChannelsConfig()
  private var mergedHandler: MergedStreamHandler?
  private var _mainFlutterViewController: FlutterViewController?

  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    statusBarController = StatusBarController()
    statusBarController?.delegate = self
    globalShortcut.delegate = self
    
    // Hide the window on startup
    if let window = flutterWindow {
      window.orderOut(nil)
    }
    
    // Setup Flutter Channels
    if let controller = mainFlutterViewController {
      setupChannels(binaryMessenger: controller.engine.binaryMessenger)
    }
    
    registerGlobalShortcutIfNeeded(promptForAccessibility: true)
    
    super.applicationDidFinishLaunching(aNotification)
  }

  override func applicationDidBecomeActive(_ notification: Notification) {
    reregisterGlobalShortcut()
    super.applicationDidBecomeActive(notification)
  }

  func reregisterGlobalShortcut() {
    globalShortcut.unregister()

    guard GlobalShortcut.isAccessibilityGranted else {
      NSLog("GlobalShortcut: waiting for accessibility permission")
      return
    }

    if !globalShortcut.register() {
      registerGlobalMonitorFallback()
    }
  }

  func registerGlobalShortcutIfNeeded(promptForAccessibility: Bool) {
    if GlobalShortcut.isAccessibilityGranted {
      reregisterGlobalShortcut()
      return
    }

    if promptForAccessibility {
      _ = GlobalShortcut.requestAccessibility(prompt: true)
    }
  }

  private var globalKeyMonitor: Any?

  private func registerGlobalMonitorFallback() {
    guard globalKeyMonitor == nil else { return }

    globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self = self else { return }

      let flags = event.modifierFlags.intersection([.command, .shift, .option, .control])
      if flags == [.command, .shift] && event.keyCode == 9 {
        self.globalShortcutDidPress()
      }
    }

    if globalKeyMonitor != nil {
      NSLog("GlobalShortcut: global monitor fallback registered")
    }
  }

  func globalShortcutDidPress() {
    toggleClipboardWindow()
  }

  private func toggleClipboardWindow() {
    guard let window = flutterWindow else {
      NSLog("toggleClipboardWindow: window not found")
      return
    }

    if window.isVisible {
      window.orderOut(nil)
    } else {
      window.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    }
  }
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "copyToClipboard":
      if let args = call.arguments as? [String: Any], let content = args["content"] as? String {
        clipboardMonitor.copyToClipboard(content)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing content", details: nil))
      }
    case "showWindow":
      if let window = flutterWindow {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
      }
      result(nil)
    case "hideWindow":
      flutterWindow?.orderOut(nil)
      result(nil)
    case "toggleWindow":
      toggleClipboardWindow()
      result(nil)
    case "isAccessibilityGranted":
      result(GlobalShortcut.isAccessibilityGranted)
    case "isShortcutRegistered":
      result(globalShortcut.isRegistered || globalKeyMonitor != nil)
    case "requestAccessibility":
      if !GlobalShortcut.isAccessibilityGranted {
        _ = GlobalShortcut.requestAccessibility(prompt: true)
        GlobalShortcut.openAccessibilitySettings()
      }
      reregisterGlobalShortcut()
      result(GlobalShortcut.isAccessibilityGranted)
    case "reregisterShortcut":
      reregisterGlobalShortcut()
      result(globalShortcut.isRegistered || globalKeyMonitor != nil)
    case "getAppBundlePath":
      result(GlobalShortcut.appBundlePath)
    case "setMonitoringEnabled":
      if let args = call.arguments as? [String: Any], let enabled = args["enabled"] as? Bool {
        clipboardMonitor.setPaused(!enabled)
        statusBarController?.setMonitoringPaused(!enabled)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing enabled", details: nil))
      }
    case "setLaunchAtLogin":
      if let args = call.arguments as? [String: Any], let enabled = args["enabled"] as? Bool {
        LaunchAtLogin.isEnabled = enabled
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing enabled", details: nil))
      }
    case "getLaunchAtLogin":
      result(LaunchAtLogin.isEnabled)
    case "copyImageToClipboard":
      if let args = call.arguments as? [String: Any], let path = args["path"] as? String {
        clipboardMonitor.copyImageToClipboard(path)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false // Keep running in the background for menu bar app
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  private var flutterWindow: MainFlutterWindow? {
    return NSApp.windows.compactMap { $0 as? MainFlutterWindow }.first
  }
  
  // MARK: - StatusBarDelegate
  
  func statusBarDidRequestOpenHistory() {
    toggleClipboardWindow()
  }
  
  func statusBarDidRequestToggleMonitoring() {
    if let controller = statusBarController {
      let isPaused = controller.isMonitoringPaused
      clipboardMonitor.setPaused(isPaused)
      // Also notify Flutter if it cares, but mostly we just pause native side.
    }
  }
  
  func statusBarDidRequestClearHistory() {
    mergedHandler?.sendEvent(["type": "clear_history"])
  }
  
  func statusBarDidRequestQuit() {
    NSApp.terminate(nil)
  }
}

struct PlatformChannelsConfig {
  let events = "com.clipboard/events"
  let methods = "com.clipboard/methods"
}

class MergedStreamHandler: NSObject, FlutterStreamHandler {
  private let monitor: ClipboardMonitor
  private let shortcut: GlobalShortcut
  private var eventSink: FlutterEventSink?
  
  init(monitor: ClipboardMonitor, shortcut: GlobalShortcut) {
    self.monitor = monitor
    self.shortcut = shortcut
  }
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    let _ = monitor.onListen(withArguments: arguments, eventSink: events)
    shortcut.setEventSink(events)
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    let _ = monitor.onCancel(withArguments: arguments)
    shortcut.setEventSink(nil)
    return nil
  }
  
  func sendEvent(_ event: Any) {
    eventSink?(event)
  }
}

extension AppDelegate {
  func setupChannels(binaryMessenger: FlutterBinaryMessenger) {
    if mergedHandler != nil { return } // Already set up
    let methodChannel = FlutterMethodChannel(name: channels.methods, binaryMessenger: binaryMessenger)
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      self?.handleMethodCall(call, result: result)
    }
    
    let eventChannel = FlutterEventChannel(name: channels.events, binaryMessenger: binaryMessenger)
    let handler = MergedStreamHandler(monitor: clipboardMonitor, shortcut: globalShortcut)
    mergedHandler = handler
    eventChannel.setStreamHandler(handler)
  }

  func setMainFlutterViewController(_ controller: FlutterViewController) {
    _mainFlutterViewController = controller
  }
  
  var mainFlutterViewController: FlutterViewController? {
    return _mainFlutterViewController ?? flutterWindow?.contentViewController as? FlutterViewController
  }
}
