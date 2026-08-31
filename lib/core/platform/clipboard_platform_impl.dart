import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Future<bool> isAccessibilityGranted() async {
    if (!Platform.isMacOS) return false;
    final result =
        await _methodChannel.invokeMethod<bool>('isAccessibilityGranted');
    return result ?? false;
  }

  @override
  Future<bool> requestAccessibility() async {
    if (!Platform.isMacOS) return false;
    final result =
        await _methodChannel.invokeMethod<bool>('requestAccessibility');
    return result ?? false;
  }

  @override
  Future<bool> isShortcutRegistered() async {
    if (!Platform.isMacOS) return false;
    final result =
        await _methodChannel.invokeMethod<bool>('isShortcutRegistered');
    return result ?? false;
  }

  @override
  Future<void> reregisterShortcut() async {
    if (!Platform.isMacOS) return;
    await _methodChannel.invokeMethod('reregisterShortcut');
  }

  @override
  Future<String> getAppBundlePath() async {
    if (!Platform.isMacOS) return '';
    final result =
        await _methodChannel.invokeMethod<String>('getAppBundlePath');
    return result ?? '';
  }

  @override
  Future<String> getExecutablePath() async {
    if (!Platform.isMacOS) return '';
    final result =
        await _methodChannel.invokeMethod<String>('getExecutablePath');
    return result ?? '';
  }

  @override
  Future<void> copyImageToClipboard(String path) async {
    await _methodChannel.invokeMethod('copyImageToClipboard', {'path': path});
  }

  @override
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(
      url.startsWith('www.') ? 'https://$url' : url,
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Future<void> openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri)) {
      throw Exception('Could not open mail client for $email');
    }
  }
}
