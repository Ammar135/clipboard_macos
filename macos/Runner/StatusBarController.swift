import Cocoa
import FlutterMacOS

protocol StatusBarDelegate: AnyObject {
    func statusBarDidRequestOpenHistory()
    func statusBarDidRequestToggleMonitoring()
    func statusBarDidRequestClearHistory()
    func statusBarDidRequestQuit()
}

class StatusBarController {
    private var statusItem: NSStatusItem
    private var monitoringMenuItem: NSMenuItem?
    private(set) var isMonitoringPaused = false
    weak var delegate: StatusBarDelegate?
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "Clipboard Manager")
            button.image?.size = NSSize(width: 18, height: 18)
        }
        
        setupMenu()
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Open Clipboard History", action: #selector(openHistory), keyEquivalent: ""))
        
        let monitorItem = NSMenuItem(title: "Pause Clipboard Monitoring", action: #selector(toggleMonitoring), keyEquivalent: "")
        monitoringMenuItem = monitorItem
        menu.addItem(monitorItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        // Set target for all items
        for item in menu.items where item.action != nil {
            item.target = self
        }
        
        statusItem.menu = menu
    }
    
    @objc private func openHistory() {
        delegate?.statusBarDidRequestOpenHistory()
    }
    
    @objc private func toggleMonitoring() {
        isMonitoringPaused.toggle()
        monitoringMenuItem?.title = isMonitoringPaused ? "Resume Clipboard Monitoring" : "Pause Clipboard Monitoring"
        delegate?.statusBarDidRequestToggleMonitoring()
    }
    
    @objc private func clearHistory() {
        delegate?.statusBarDidRequestClearHistory()
    }
    
    @objc private func quit() {
        delegate?.statusBarDidRequestQuit()
    }
    
    func setMonitoringPaused(_ paused: Bool) {
        isMonitoringPaused = paused
        monitoringMenuItem?.title = paused ? "Resume Clipboard Monitoring" : "Pause Clipboard Monitoring"
    }
}
