import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/detail_screen.dart';
import 'screens/empty_screen.dart';
import 'screens/form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'state/app_state.dart';
import 'theme/tokens.dart';

class TapestryApp extends StatelessWidget {
  const TapestryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tapestry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: T.paper,
        fontFamily: T.sansFamily,
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const _Shell(),
    );
  }
}

/// Single-stack view switch (home ↔ detail, home → form, home → settings →
/// empty). The phone-class layout is constrained and centered so it reads the
/// same on a wide window or a real device.
class _Shell extends StatelessWidget {
  const _Shell();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    Widget body;
    if (state.loading) {
      body = const SizedBox.shrink();
    } else {
      switch (state.view) {
        case AppView.home:
          body = HomeScreen(state);
          break;
        case AppView.detail:
          body = DetailScreen(state);
          break;
        case AppView.form:
          body = FormScreen(state, key: ValueKey(state.draft?.editingId ?? 'new'));
          break;
        case AppView.settings:
          body = SettingsScreen(state);
          break;
        case AppView.empty:
          body = EmptyScreen(state);
          break;
      }
    }

    return Scaffold(
      backgroundColor: T.paper,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey(state.view),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
