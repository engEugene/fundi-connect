import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../features/auth/screens/create_account_screen.dart';
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/verify_phone_screen.dart';
import '../../features/bookings/screens/booking_detail_screen.dart';
import '../../features/bookings/screens/bookings_screen.dart';
import '../../features/bookings/screens/confirm_booking_screen.dart';
import '../../features/bookings/screens/worker_dashboard_screen.dart';
import '../../features/discover/screens/discover_screen.dart';
import '../../features/discover/screens/worker_detail_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../core/widgets/shell_scaffold.dart';

/// Application router.
///
/// This file is the only place where routes are wired together. Feature owners
/// should only touch their own screen files; adding or changing paths should
/// be discussed with the team to avoid conflicts.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.onboarding,
    debugLogDiagnostics: true,
    routes: [
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
        path: RouteNames.verifyPhone,
        builder: (context, state) => const VerifyPhoneScreen(),
      ),

      // Worker public profile (full-screen, no bottom nav)
      GoRoute(
        path: RouteNames.workerDetail,
        builder: (context, state) => WorkerDetailScreen(
          workerId: state.pathParameters['id']!,
        ),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.discover,
            builder: (context, state) => const DiscoverScreen(),
          ),
          GoRoute(
            path: RouteNames.bookings,
            builder: (context, state) => const BookingsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => BookingDetailScreen(
                  bookingId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'confirm',
                builder: (context, state) => const ConfirmBookingScreen(),
              ),
              GoRoute(
                path: 'dashboard',
                builder: (context, state) => const WorkerDashboardScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
