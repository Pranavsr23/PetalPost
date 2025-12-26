import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../data/models/note.dart";
import "../../features/anniversary/anniversary_screen.dart";
import "../../features/auth/auth_screen.dart";
import "../../features/auth/onboarding_screen.dart";
import "../../features/handwriting/handwriting_screen.dart";
import "../../features/home/home_screen.dart";
import "../../features/love_jar/love_jar_screen.dart";
import "../../features/love_jar/memories_screen.dart";
import "../../features/notes/compose_note_screen.dart";
import "../../features/profile/profile_setup_screen.dart";
import "../../features/reveal/reveal_screen.dart";
import "../../features/rewards/rewards_screen.dart";
import "../../features/settings/settings_screen.dart";
import "../../features/spaces/create_space_screen.dart";
import "../../features/spaces/invite_partner_screen.dart";
import "../../features/spaces/join_space_screen.dart";
import "../../features/spaces/space_setup_screen.dart";
import "../../features/splash/splash_screen.dart";
import "../../features/voice/voice_record_screen.dart";
import "../../features/widgets/widget_tutorial_screen.dart";
import "../../providers/auth_providers.dart";
import "../../providers/data_providers.dart";

class AppRouter {
  static GoRouter create(Ref ref) {
    final refreshNotifier = GoRouterRefreshStream();
    final authListener = ref.listen(authStateProvider, (_, __) {
      refreshNotifier.notify();
    });
    ref.onDispose(authListener.close);
    ref.onDispose(refreshNotifier.dispose);

    return GoRouter(
      initialLocation: SplashScreen.routePath,
      refreshListenable: refreshNotifier,
      redirect: (context, state) {
        final authAsync = ref.read(authStateProvider);
        final profileAsync = ref.read(userProfileProvider);
        final isLoggingIn = state.matchedLocation == AuthScreen.routePath ||
            state.matchedLocation == OnboardingScreen.routePath ||
            state.matchedLocation == ProfileSetupScreen.routePath;
        final isProfileSetup =
            state.matchedLocation == ProfileSetupScreen.routePath;
        final isSplash = state.matchedLocation == SplashScreen.routePath;

        return authAsync.when(
          data: (user) {
            if (user == null) {
              return isLoggingIn || isSplash ? null : AuthScreen.routePath;
            }
            if (profileAsync is AsyncLoading) {
              return SplashScreen.routePath;
            }
            if (profileAsync is AsyncData &&
                profileAsync.value == null &&
                !isProfileSetup) {
              return ProfileSetupScreen.routePath;
            }
            if (isLoggingIn || isSplash) {
              return HomeScreen.routePath;
            }
            return null;
          },
          loading: () => isSplash ? null : SplashScreen.routePath,
          error: (_, __) => AuthScreen.routePath,
        );
      },
      routes: [
        GoRoute(
          path: SplashScreen.routePath,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AuthScreen.routePath,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: OnboardingScreen.routePath,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: ProfileSetupScreen.routePath,
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        GoRoute(
          path: HomeScreen.routePath,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: ComposeNoteScreen.routePath,
          builder: (context, state) => const ComposeNoteScreen(),
        ),
        GoRoute(
          path: RevealScreen.routePath,
          builder: (context, state) => RevealScreen(note: state.extra as Note?),
        ),
        GoRoute(
          path: HandwritingScreen.routePath,
          builder: (context, state) => const HandwritingScreen(),
        ),
        GoRoute(
          path: VoiceRecordScreen.routePath,
          builder: (context, state) => const VoiceRecordScreen(),
        ),
        GoRoute(
          path: LoveJarScreen.routePath,
          builder: (context, state) => const LoveJarScreen(),
        ),
        GoRoute(
          path: MemoriesScreen.routePath,
          builder: (context, state) => const MemoriesScreen(),
        ),
        GoRoute(
          path: RewardsScreen.routePath,
          builder: (context, state) => const RewardsScreen(),
        ),
        GoRoute(
          path: SettingsScreen.routePath,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: WidgetTutorialScreen.routePath,
          builder: (context, state) => const WidgetTutorialScreen(),
        ),
        GoRoute(
          path: CreateSpaceScreen.routePath,
          builder: (context, state) => const CreateSpaceScreen(),
        ),
        GoRoute(
          path: JoinSpaceScreen.routePath,
          builder: (context, state) => const JoinSpaceScreen(),
        ),
        GoRoute(
          path: InvitePartnerScreen.routePath,
          builder: (context, state) => const InvitePartnerScreen(),
        ),
        GoRoute(
          path: SpaceSetupScreen.routePath,
          builder: (context, state) => const SpaceSetupScreen(),
        ),
        GoRoute(
          path: AnniversaryScreen.routePath,
          builder: (context, state) => const AnniversaryScreen(),
        ),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  void notify() => notifyListeners();
}
