/// Central place for all route path constants.
///
/// Each team member owns a feature branch of routes. Keep paths stable so
/// deep-links and navigation calls do not break across PRs.
class RouteNames {
  RouteNames._();

  // Onboarding
  static const String onboarding = '/';

  // Auth
  static const String auth = '/auth';
  static const String roleSelect = '$auth/role-select';
  static const String signIn = '$auth/sign-in';
  static const String createAccount = '$auth/create-account';
  static const String verifyPhone = '$auth/verify-phone';

  // Main shell (bottom nav)
  static const String home = '/home';
  static const String discover = '/discover';
  static const String bookings = '/bookings';
  static const String profile = '/profile';

  // Worker public profile (full-screen, no bottom nav)
  static const String workerDetail = '/worker/:id';

  // Booking sub-flows
  static const String bookingDetail = '$bookings/:id';
  static const String confirmBooking = '$bookings/confirm';
  static const String workerDashboard = '$bookings/dashboard';

  // Profile sub-flows
  static const String editProfile = '$profile/edit';
  static const String settings = '$profile/settings';
}
