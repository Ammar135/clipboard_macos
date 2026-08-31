import Cocoa
import FlutterMacOS

class ClipboardMonitor: NSObject, FlutterStreamHandler {
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    private var eventSink: FlutterEventSink?
    private var isPaused = false
    
    // Protection against self-generated copies
    private var lastCopiedByUs: String?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startMonitoring()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopMonitoring()
        self.eventSink = nil
        return nil
    }
    
    func setPaused(_ paused: Bool) {
        self.isPaused = paused
    }
    
    func copyToClipboard(_ content: String) {
        lastCopiedByUs = content
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }
    
    func copyImageToClipboard(_ path: String) {
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url),
              let image = NSImage(data: data) else { return }
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
        lastChangeCount = pasteboard.changeCount
    }
    
    private func startMonitoring() {
        lastChangeCount = pasteboard.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkForChanges() {
        guard !isPaused else { return }
        
        let currentChangeCount = pasteboard.changeCount
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            
            // Check for image data first
            if let types = pasteboard.types, types.contains(.png) || types.contains(.tiff) {
                // Prefer PNG data
                var imageData: Data?
                if let data = pasteboard.data(forType: .png) {
                    imageData = data
                } else if let data = pasteboard.data(forType: .tiff) {
                    // Convert TIFF to PNG
                    if let _ = NSImage(data: data) {
                        let rep = NSBitmapImageRep(data: data)
                        imageData = rep?.representation(using: .png, properties: [:])
                    }
                }
                if let imgData = imageData {
                    // Save to cache directory with unique filename
                    let uuid = UUID().uuidString
                    let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                    let fileURL = caches.appendingPathComponent("\(uuid).png")
                    try? imgData.write(to: fileURL)
                    let sourceApp = NSWorkspace.shared.frontmostApplication?.localizedName
                    let event: [String: Any] = [
                        "event": "clipboard_changed",
                        "content": fileURL.path,
                        "type": "image",
                        "sourceApp": sourceApp ?? ""
                    ]
                    eventSink?(event)
                }
            } else if let newString = pasteboard.string(forType: .string) {
                // Ignore if it's the exact same string we just copied ourselves
                if lastCopiedByUs == newString {
                    lastCopiedByUs = nil
                    return
                }
                
                // Get source app if available
                let sourceApp = NSWorkspace.shared.frontmostApplication?.localizedName
                
                let event: [String: Any] = [
                    "event": "clipboard_changed",
                    "content": newString,
                    "type": "text",
                    "sourceApp": sourceApp ?? ""
                ]
                
                eventSink?(event)
            }
        }
    }
}
