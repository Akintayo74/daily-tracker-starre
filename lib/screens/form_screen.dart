import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

/// Add / Edit a thread — one form, two modes.
class FormScreen extends StatefulWidget {
  const FormScreen(this.state, {super.key});
  final AppState state;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.state.draft?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 9),
        child: Text(text, style: T.eyebrow()),
      );

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final d = state.draft;
    if (d == null) return const SizedBox.shrink();
    final hue = T.palette[d.hueIdx];
    final can = state.canCommit;
    final isEdit = d.isEdit;
    final everyDay = d.days.every((x) => x);
    const dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 58, 22, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: state.cancelForm,
                behavior: HitTestBehavior.opaque,
                child: Text('Cancel', style: T.sans(size: 14, color: T.faint)),
              ),
              Text(isEdit ? 'Edit thread' : 'New thread', style: T.serif(size: 18, color: const Color(0xFF544C42))),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 18),

          // Live preview.
          Container(
            decoration: BoxDecoration(
              color: hue.wash,
              border: Border.all(color: T.cardBorder),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hue.solid(),
                    boxShadow: [BoxShadow(color: hue.solid(0.16), spreadRadius: 4)],
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    d.name.trim().isEmpty ? 'Your thread' : d.name.trim(),
                    style: T.serif(size: 21, color: d.name.trim().isEmpty ? const Color(0xFFC2B8A6) : T.ink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Name.
          _label('NAME'),
          TextField(
            controller: _name,
            onChanged: state.setDraftName,
            cursorColor: T.ink2,
            style: T.sans(size: 16, color: T.ink2),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'e.g. Wake at 5:00',
              hintStyle: T.sans(size: 16, color: const Color(0xFFB1A896)),
              filled: true,
              fillColor: T.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: T.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: T.inputBorder),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Color.
          _label('COLOR'),
          Wrap(
            spacing: 11,
            runSpacing: 11,
            children: [
              for (var i = 0; i < T.palette.length; i++)
                _Swatch(
                  hue: T.palette[i],
                  selected: i == d.hueIdx,
                  onTap: () => state.setDraftHue(i),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Rhythm.
          _label('RHYTHM'),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: state.setEveryDay,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: everyDay ? T.hairline : Colors.transparent,
                  border: Border.all(color: everyDay ? const Color(0xFFBCAB8A) : const Color(0xFFE2DACA)),
                ),
                child: Text('Every day',
                    style: T.sans(size: 13, weight: FontWeight.w500, color: everyDay ? const Color(0xFF564E43) : const Color(0xFF9A9082))),
              ),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                _DayPill(
                  label: dayNames[i],
                  on: d.days[i],
                  hue: hue,
                  onTap: () => state.toggleDraftDay(i),
                ),
              ],
            ],
          ),

          // Primary.
          const SizedBox(height: 28),
          GestureDetector(
            onTap: can ? state.commitForm : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: can ? hue.solid() : T.inputBorder,
              ),
              child: Text(
                isEdit ? 'Save changes' : 'Add to the loom',
                style: T.sans(size: 16, weight: FontWeight.w600, color: can ? T.darkButtonText : const Color(0xFFB1A896)),
              ),
            ),
          ),

          // Destructive (edit only).
          if (isEdit) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => state.archiveHabit(d.editingId!),
                  behavior: HitTestBehavior.opaque,
                  child: Text('Archive thread', style: T.sans(size: 14, color: T.faint)),
                ),
                const SizedBox(width: 26),
                GestureDetector(
                  onTap: () => _confirmDelete(context, state, d.editingId!),
                  behavior: HitTestBehavior.opaque,
                  child: Text('Delete', style: T.sans(size: 14, color: T.destructive)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String id) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: T.surface,
        title: Text('Delete this thread?', style: T.serif(size: 20, color: T.ink)),
        content: Text('Its history will be removed for good. To keep the history, archive it instead.',
            style: T.sans(size: 14, color: T.muted, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Keep', style: T.sans(size: 14, color: T.faint)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              state.deleteHabit(id);
            },
            child: Text('Delete', style: T.sans(size: 14, weight: FontWeight.w600, color: T.destructive)),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.hue, required this.selected, required this.onTap});
  final HabitHue hue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hue.solid(),
          border: Border.all(
            color: selected ? T.darkButton : Colors.transparent,
            width: selected ? 2.5 : 2,
          ),
          boxShadow: selected
              ? const [BoxShadow(color: T.paper, spreadRadius: 2)]
              : const [BoxShadow(color: Color(0x263C2D14), blurRadius: 3, offset: Offset(0, 1))],
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({required this.label, required this.on, required this.hue, required this.onTap});
  final String label;
  final bool on;
  final HabitHue hue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: on ? hue.solid(0.16) : Colors.transparent,
          border: Border.all(color: on ? hue.solid(0.5) : const Color(0xFFE2DACA)),
        ),
        child: Text(label,
            style: T.sans(size: 14, weight: FontWeight.w600, color: on ? const Color(0xFF564E43) : const Color(0xFFB1A896))),
      ),
    );
  }
}
