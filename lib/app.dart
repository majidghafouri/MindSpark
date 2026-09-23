import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/models/day_result.dart';
import 'presentation/screens/challenge_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/results_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/stats_screen.dart';
import 'presentation/state/app_state.dart';
import 'presentation/state/game_session.dart';
import 'presentation/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key, required this.appState});

  final AppState appState;

  ThemeMode _modeOf(AppState state) {
    switch (state.settings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.isReady) {
            return MaterialApp(
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return MaterialApp(
            title: 'NeverMindSpark',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _modeOf(state),
            home: state.settings.onboardingCompleted
                ? const HomeScreen()
                : OnboardingScreen(onDone: state.completeOnboarding),
            routes: {
              Routes.stats: (_) => const StatsScreen(),
              Routes.settings: (_) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case Routes.challenge:
                  final session = settings.arguments as GameSession;
                  return MaterialPageRoute(
                    builder: (_) => ChallengeScreen(session: session),
                  );
                case Routes.results:
                  final result = settings.arguments as DayResult;
                  return MaterialPageRoute(
                    builder: (_) => ResultsScreen(result: result),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}