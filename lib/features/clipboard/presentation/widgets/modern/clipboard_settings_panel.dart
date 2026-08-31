import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/clipboard_ui_colors.dart';
import '../../theme/clipboard_ui_dimensions.dart';
import '../../theme/clipboard_ui_typography.dart';

class ClipboardAppShortcuts {
  static const openPanel = '⌘⇧V';
}

class ClipboardSettingsPanel extends StatelessWidget {
  final bool launchAtLogin;
  final bool isLoading;
  final bool accessibilityGranted;
  final bool shortcutRegistered;
  final String appBundlePath;
  final ValueChanged<bool> onLaunchAtLoginChanged;
  final VoidCallback onRequestAccessibilityTap;
  final VoidCallback onBackTap;
  final VoidCallback onCloseTap;

  const ClipboardSettingsPanel({
    super.key,
    required this.launchAtLogin,
    required this.isLoading,
    required this.accessibilityGranted,
    required this.shortcutRegistered,
    required this.appBundlePath,
    required this.onLaunchAtLoginChanged,
    required this.onRequestAccessibilityTap,
    required this.onBackTap,
    required this.onCloseTap,
  });

  String get _shortcutStatusLabel {
    if (shortcutRegistered) {
      return accessibilityGranted
          ? 'Shortcut is active system-wide'
          : 'Shortcut is active (hotkey registered)';
    }
    if (!accessibilityGranted) {
      return 'Shortcut not active — enable Accessibility for this exact .app build';
    }
    return 'Accessibility granted — quit and reopen the app once';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsHeader(onBackTap: onBackTap, onCloseTap: onCloseTap),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              ClipboardUiDimensions.contentPadding,
              8,
              ClipboardUiDimensions.contentPadding,
              16,
            ),
            children: [
              _SettingsSection(
                title: 'Startup',
                children: [
                  _SettingsToggleRow(
                    title: 'Launch at login',
                    subtitle: 'Start Clipboard Manager when you sign in',
                    value: launchAtLogin,
                    isLoading: isLoading,
                    onChanged: onLaunchAtLoginChanged,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: 'Shortcuts',
                children: [
                  _SettingsInfoRow(
                    title: 'Open clipboard panel',
                    value: ClipboardAppShortcuts.openPanel,
                    subtitle: _shortcutStatusLabel,
                    statusColor: shortcutRegistered
                        ? const Color(0xFF34C759)
                        : ClipboardUiColors.textSecondary,
                  ),
                  if (!shortcutRegistered) ...[
                    const Divider(height: 1, color: ClipboardUiColors.divider),
                    _SettingsActionRow(
                      title: 'Open Accessibility Settings',
                      onTap: onRequestAccessibilityTap,
                    ),
                    if (appBundlePath.isNotEmpty) ...[
                      const Divider(height: 1, color: ClipboardUiColors.divider),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enable this app in the list:',
                              style: ClipboardUiTypography.cardMeta(),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              appBundlePath,
                              style: ClipboardUiTypography.cardTitle().copyWith(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1. Remove any old clipboard_project entries\n'
                              '2. Click + and select this exact .app file\n'
                              '3. Turn the toggle ON\n'
                              '4. Quit and reopen the app (required after release builds)',
                              style: ClipboardUiTypography.cardMeta(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onCloseTap;

  const _SettingsHeader({
    required this.onBackTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: CupertinoIcons.chevron_left,
            onTap: onBackTap,
          ),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: ClipboardUiTypography.cardTitle(),
            ),
          ),
          _HeaderIconButton(
            icon: CupertinoIcons.xmark,
            onTap: onCloseTap,
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: ClipboardUiTypography.footerHint().copyWith(
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ClipboardUiColors.cardFill,
            borderRadius: BorderRadius.circular(ClipboardUiDimensions.cardRadius),
            border: Border.all(color: ClipboardUiColors.borderSubtle),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ClipboardUiTypography.cardTitle()),
                const SizedBox(height: 4),
                Text(subtitle, style: ClipboardUiTypography.cardMeta()),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CupertinoActivityIndicator(radius: 8),
            )
          else
            CupertinoSwitch(
              value: value,
              activeTrackColor: ClipboardUiColors.accent,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}

class _SettingsInfoRow extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color statusColor;

  const _SettingsInfoRow({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: ClipboardUiTypography.cardTitle()),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ClipboardUiColors.chipInactiveFill,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ClipboardUiColors.chipInactiveBorder),
                ),
                child: Text(
                  value,
                  style: ClipboardUiTypography.chipLabel(isActive: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: ClipboardUiTypography.cardMeta().copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsActionRow({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: ClipboardUiTypography.cardTitle().copyWith(
                    color: ClipboardUiColors.accent,
                  ),
                ),
              ),
              const Icon(
                CupertinoIcons.arrow_up_right,
                size: 14,
                color: ClipboardUiColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 15,
            color: ClipboardUiColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
