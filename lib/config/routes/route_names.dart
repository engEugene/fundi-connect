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

  // Discover sub-flows
  static const String searchResults = '$discover/search';
  static const String workerDetail = '$discover/worker/:id';

  // Booking sub-flows
  static const String confirmBooking = '$bookings/confirm';
  static const String workerDashboard = '$bookings/dashboard';
}
