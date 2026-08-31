import Cocoa
import ServiceManagement

class LaunchAtLogin {
  static var isEnabled: Bool {
    get {
      return SMAppService.mainApp.status == .enabled
    }
    set {
      do {
        if newValue {
          if SMAppService.mainApp.status == .enabled { return }
          try SMAppService.mainApp.register()
        } else {
          try SMAppService.mainApp.unregister()
        }
      } catch {
        print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error)")
      }
    }
  }
}
