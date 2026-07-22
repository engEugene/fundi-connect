import '../../../../core/models/worker.dart';

/// Mock signed-in tradesman for the tradesman profile UI.
///
/// Firebase will replace this later; for now the profile screens read from here
/// so the layout can be built and reviewed without a backend.
class ProfileMock {
  ProfileMock._();

  /// The worker whose profile is being viewed/edited.
  static final Worker currentUser = Worker.nearby.first;

  static const String district = 'Kigali';
  static const String phone = '+250 788 123 456';
  static const String email = 'jp.habimana@example.com';

  /// Trade categories offered in the Edit Profile dropdown.
  static const List<String> tradeCategories = [
    'Plumber',
    'Electrician',
    'Carpenter',
    'Cleaner',
    'Mason',
  ];

  static const List<String> districts = [
    'Kigali',
    'Musanze',
    'Rubavu',
    'Huye',
    'Muhanga',
  ];
}
