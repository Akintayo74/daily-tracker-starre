import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

/// Settings (slim) — the few real knobs.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen(this.state, {super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 58, 22, 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: state.goHome,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('‹', style: T.sans(size: 18, color: T.faint, height: 1)),
                const SizedBox(width: 5),
                Text('Loom', style: T.sans(size: 14, color: T.faint)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Settings', style: T.serif(size: 29, color: T.ink)),
          const SizedBox(height: 24),

          _Group(children: [
            _Row(
              title: 'Week starts on',
              trailing: Text(state.weekStart == 'sun' ? 'Sunday' : 'Monday', style: T.sans(size: 14, color: const Color(0xFFA59B8A))),
              onTap: state.toggleWeekStart,
            ),
            _Row(
              title: 'Reminders',
              subtitle: 'Kept quiet for now — the cloth is nudge enough.',
              trailing: Text('Off', style: T.sans(size: 14, color: T.faint3)),
            ),
            _Row(
              title: 'Appearance',
              trailing: Text('Warm', style: T.sans(size: 14, color: const Color(0xFFA59B8A))),
              isLast: true,
            ),
          ]),
          const SizedBox(height: 16),

          _Group(children: const [
            _Row(title: 'Export data', trailing: _Chevron()),
            _Row(title: 'Backup & restore', trailing: _Chevron(), isLast: true),
          ]),
          const SizedBox(height: 16),

          _Group(children: [
            _Row(title: 'See first-run screen', trailing: const _Chevron(), onTap: state.goEmpty),
            const _Row(title: 'About the loom', trailing: _Chevron(), isLast: true),
          ]),
          const SizedBox(height: 24),

          Text('Tapestry · woven gently · v0.3',
              textAlign: TextAlign.center, style: T.sans(size: 11.5, color: const Color(0xFFC3B9A3))),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: T.surface,
        border: Border.all(color: T.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, this.subtitle, required this.trailing, this.onTap, this.isLast = false});
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: subtitle == null ? 15 : 13),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: T.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: T.sans(size: 15, color: T.ink2)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: T.sans(size: 12, color: const Color(0xFFB0A692))),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();
  @override
  Widget build(BuildContext context) => Text('›', style: T.sans(size: 17, color: T.chevron));
}
