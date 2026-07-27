import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/create_account_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/client/bookings/screens/booking_detail_screen.dart' as client;
import '../../features/client/bookings/screens/bookings_screen.dart' as client;
import '../../features/client/bookings/screens/confirm_booking_screen.dart' as client;
import '../../features/client/discover/screens/discover_screen.dart' as client;
import '../../features/client/discover/screens/worker_detail_screen.dart';
import '../../features/client/home/screens/home_screen.dart' as client;
import '../../features/client/profile/screens/edit_profile_screen.dart' as client;
import '../../features/client/profile/screens/profile_screen.dart' as client;
import '../../features/client/profile/screens/settings_screen.dart' as client;
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/tradesman/bookings/screens/bookings_screen.dart';
import '../../features/tradesman/bookings/screens/job_request_detail_screen.dart';
import '../../features/tradesman/dashboard/screens/worker_dashboard_screen.dart';
import '../../features/tradesman/discover/screens/discover_screen.dart';
import '../../features/tradesman/home/screens/home_screen.dart';
import '../../features/tradesman/profile/screens/edit_profile_screen.dart';
import '../../features/tradesman/profile/screens/profile_screen.dart';
import '../../core/widgets/shell_scaffold.dart';

/// Notifies [GoRouter] when [authProvider] changes without recreating the router.
class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(this.ref) {
    _subscription = ref.listen<AuthState>(
      authProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref ref;
  ProviderSubscription<AuthState>? _subscription;

  AuthState get state => ref.read(authProvider);

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }
}

/// Provider that creates the auth router notifier. It is intentionally a plain
/// [Provider] (not a [ChangeNotifierProvider]) so that [routerProvider] does not
/// rebuild every time the notifier calls [notifyListeners]. The notifier itself
/// listens to [authProvider] and notifies [GoRouter] via [refreshListenable].
final _authRouterNotifierProvider = Provider<_AuthRouterNotifier>((ref) {
  final notifier = _AuthRouterNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Application router provider.
///
/// Uses [refreshListenable] so redirects react to sign-in / sign-out while the
/// [GoRouter] instance stays alive. This prevents navigation resets when the
/// selected role changes on the role-select screen.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_authRouterNotifierProvider);

  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: RouteNames.onboarding,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) => AppRouter.redirect(notifier.state, state),
    routes: AppRouter.routes,
  );
});

/// Application router.
///
/// This file is the only place where routes are wired together. Feature owners
/// should only touch their own screen files; adding or changing paths should
/// be discussed with the team to avoid conflicts.
///
/// The same four bottom-nav destinations exist for both roles, but the actual
/// screens rendered inside them live under [features/client] or
/// [features/tradesman] depending on the signed-in user's role.
class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static String? redirect(AuthState authState, GoRouterState state) {
    final location = state.uri.path;

    // Show a blank splash while Firebase checks the cached session.
    if (authState.initializing && location != RouteNames.splash) {
      return RouteNames.splash;
    }

    final isAuthRoute = location == RouteNames.onboarding ||
        location == RouteNames.splash ||
        location.startsWith(RouteNames.auth);
    final isProtectedRoute = location.startsWith(RouteNames.home) ||
        location.startsWith(RouteNames.discover) ||
        location.startsWith(RouteNames.bookings) ||
        location.startsWith(RouteNames.profile) ||
        location.startsWith('/worker/');

    if (!authState.isAuthenticated) {
      // Keep logged-out users on the auth flow; send everything else to onboarding.
      if (isProtectedRoute || location == RouteNames.splash) {
        return RouteNames.onboarding;
      }
      return null;
    }

    final emailVerified = authState.authenticatedUser?.emailVerified ?? false;

    if (!emailVerified) {
      // Authenticated users with unverified email must verify first.
      if (location == RouteNames.verifyEmail) return null;
      return RouteNames.verifyEmail;
    }

    // Authenticated users with verified email should not land on auth screens.
    if (isAuthRoute) return RouteNames.home;

    return null;
  }

  static List<RouteBase> get routes => [
    // Splash
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const _SplashScreen(),
    ),

    // Onboarding
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Auth
    GoRoute(
      path: RouteNames.roleSelect,
      builder: (context, state) => const RoleSelectScreen(),
    ),
    GoRoute(
      path: RouteNames.signIn,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: RouteNames.createAccount,
      builder: (context, state) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: RouteNames.verifyEmail,
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Worker public profile (full-screen, no bottom nav)
    GoRoute(
      path: RouteNames.workerDetail,
      builder: (context, state) =>
          WorkerDetailScreen(workerId: state.pathParameters['id']!),
    ),

    // Main app shell with bottom navigation.
    // The child rendered by each tab is chosen from the client or tradesman
    // feature folders based on the current role.
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) => _RoleAwareHomeScreen(),
        ),
        GoRoute(
          path: RouteNames.discover,
          builder: (context, state) => _RoleAwareDiscoverScreen(),
        ),
        GoRoute(
          path: RouteNames.bookings,
          builder: (context, state) => _RoleAwareBookingsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => _RoleAwareBookingDetailScreen(
                bookingId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'confirm',
              builder: (context, state) => const client.ConfirmBookingScreen(),
            ),
            GoRoute(
              path: 'dashboard',
              builder: (context, state) => const WorkerDashboardScreen(),
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (context, state) => _RoleAwareProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => _RoleAwareEditProfileScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const client.SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ];
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Returns the client or tradesman home screen based on the role.
class _RoleAwareHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((s) => s.currentRole));
    return role == UserRole.worker
        ? const TradesmanHomeScreen()
        : const client.HomeScreen();
  }
}

/// Returns the client or tradesman discover screen based on the role.
class _RoleAwareDiscoverScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((s) => s.currentRole));
    return role == UserRole.worker
        ? const TradesmanDiscoverScreen()
        : const client.DiscoverScreen();
  }
}

/// Returns the client or tradesman bookings screen based on the role.
class _RoleAwareBookingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((s) => s.currentRole));
    return role == UserRole.worker
        ? const TradesmanBookingsScreen()
        : const client.BookingsScreen();
  }
}

/// Returns the client booking detail or the tradesman job request detail.
class _RoleAwareBookingDetailScreen extends ConsumerWidget {
  const _RoleAwareBookingDetailScreen({required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((s) => s.currentRole));
    return role == UserRole.worker
        ? TradesmanJobRequestDetailScreen(bookingId: bookingId)
        : client.BookingDetailScreen(bookingId: bookingId);
  }
}

/// Returns the client or tradesman profile screen based on the role.
class _RoleAwareProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((s) => s.currentRole));
    return role == UserRole.worker
        ? const TradesmanProfileScreen()
        : const client.ProfileScreen();
  }
}

/// Returns the client or tradesman edit profile screen.
class _RoleAwareEditProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((s) => s.currentRole));
    return role == UserRole.worker
        ? const TradesmanEditProfileScreen()
        : const client.EditProfileScreen();
  }
}
