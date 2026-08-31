import 'package:flutter/services.dart';
import 'clipboard_platform.dart';
import 'platform_channels.dart';

class ClipboardPlatformImpl implements ClipboardPlatform {
  final _methodChannel = const MethodChannel(PlatformChannels.methods);
  final _eventChannel = const EventChannel(PlatformChannels.clipboardEvents);
  
  Stream<Map<String, dynamic>>? _eventsStream;

  @override
  Stream<Map<String, dynamic>> get events {
    _eventsStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => Map<String, dynamic>.from(event as Map));
    return _eventsStream!;
  }

  @override
  Future<void> copyToClipboard(String content) async {
    await _methodChannel.invokeMethod('copyToClipboard', {'content': content});
  }

  @override
  Future<void> showWindow() async {
    await _methodChannel.invokeMethod('showWindow');
  }

  @override
  Future<void> hideWindow() async {
    await _methodChannel.invokeMethod('hideWindow');
  }

  @override
  Future<bool> getLaunchAtLogin() async {
    final result = await _methodChannel.invokeMethod<bool>('getLaunchAtLogin');
    return result ?? false;
  }

  @override
  Future<void> setLaunchAtLogin(bool enabled) async {
    await _methodChannel.invokeMethod('setLaunchAtLogin', {'enabled': enabled});
  }

  @override
  Future<void> setMonitoringEnabled(bool enabled) async {
    await _methodChannel.invokeMethod('setMonitoringEnabled', {'enabled': enabled});
  }

  @override
  Future<void> copyImageToClipboard(String path) async {
    await _methodChannel.invokeMethod('copyImageToClipboard', {'path': path});
  }
}
