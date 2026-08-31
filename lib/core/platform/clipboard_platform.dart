abstract interface class ClipboardPlatform {
  Stream<Map<String, dynamic>> get events;
  
  Future<void> copyToClipboard(String content);
  Future<void> copyImageToClipboard(String path);
  
  Future<void> showWindow();
  
  Future<void> hideWindow();
  
  Future<bool> getLaunchAtLogin();
  
  Future<void> setLaunchAtLogin(bool enabled);
  
  Future<void> setMonitoringEnabled(bool enabled);

  Future<bool> isAccessibilityGranted();

  Future<bool> requestAccessibility();

  Future<bool> isShortcutRegistered();

  Future<void> reregisterShortcut();

  Future<String> getAppBundlePath();

  Future<String> getExecutablePath();

  Future<void> openUrl(String url);

  Future<void> openEmail(String email);
}
