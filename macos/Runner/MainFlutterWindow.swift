import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSPanel {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = NSRect(x: 0, y: 0, width: 450, height: 600)
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Panel styling
    self.styleMask = [.titled, .fullSizeContentView, .nonactivatingPanel]
    self.level = .floating
    self.collectionBehavior = [.canJoinAllSpaces, .ignoresCycle]
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.isOpaque = false
    self.backgroundColor = NSColor.clear
    self.isMovableByWindowBackground = true
    
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
      appDelegate.setupChannels(binaryMessenger: flutterViewController.engine.binaryMessenger)
      appDelegate.setMainFlutterViewController(flutterViewController)
    }

    super.awakeFromNib()
  }
  
  // Required for NSPanel to accept keyboard input
  override var canBecomeKey: Bool {
      return true
  }
  
  override var canBecomeMain: Bool {
      return true
  }
}
