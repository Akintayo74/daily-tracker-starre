import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/home_widgets.dart';

/// Empty / first run — the zero-threads state; routes to creating the first.
class EmptyScreen extends StatelessWidget {
  const EmptyScreen(this.state, {super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 58, 30, 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: state.goHome,
            behavior: HitTestBehavior.opaque,
            child: Text('‹ Loom', style: T.sans(size: 14, color: T.faint)),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EmptyLoom(),
                  const SizedBox(height: 30),
                  Text('Your loom is empty', style: T.serif(size: 29, color: T.ink)),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      'Weave in the small things — a walk at dawn, a poem, a steady bedtime. Watch the days slowly take on color.',
                      textAlign: TextAlign.center,
                      style: T.sans(size: 15, color: T.muted, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: state.startAdd,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                      decoration: BoxDecoration(
                        color: T.darkButton,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('Add your first thread',
                          style: T.sans(size: 15, weight: FontWeight.w600, color: T.darkButtonText)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
