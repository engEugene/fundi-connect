// no flutter stuff so this works with any backend
class Validators {
  Validators._();

  static const int minPasswordLength = 8;

  // 6 digits bcs firebase, not 4 like Figma
  static const int otpLength = 6;

  static const String defaultDialCode = '+250';

  static final _email = RegExp(r'^[\w.+-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your full name';
    if (!name.contains(' ')) return 'Enter both your first and last name';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    if (!_email.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  static String? dialCode(String? value) {
    final digits = digitsOnly(value ?? '');
    if (digits.isEmpty) return 'Required';
    if (digits.length > 4) return 'Too long';
    return null;
  }

  // 6-14 digits covers pretty much every country
  static String? phone(String? value) {
    final digits = normalizeLocal(value ?? '');
    if (digits.isEmpty) return 'Enter your phone number';
    if (digits.length < 6 || digits.length > 14) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter a password';
    if (password.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'Include at least one letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) return 'Include at least one number';
    return null;
  }

  // no strength rules here, older accounts might have weak passwords
  static String? signInPassword(String? value) =>
      (value ?? '').isEmpty ? 'Password is required' : null;

  static String? otp(String? value) {
    final digits = digitsOnly(value ?? '');
    if (digits.isEmpty) return 'Enter the verification code';
    if (digits.length != otpLength) return 'Enter all $otpLength digits';
    return null;
  }

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  // strip leading 0 bcs E.164 format doesn't use it, e.g. 078 -> 78
  static String normalizeLocal(String value) {
    final digits = digitsOnly(value);
    return digits.startsWith('0') ? digits.substring(1) : digits;
  }

  static String toE164(String dialCode, String localNumber) =>
      '+${digitsOnly(dialCode)}${normalizeLocal(localNumber)}';

  static String maskPhone(String dialCode, String localNumber) {
    final full = toE164(dialCode, localNumber);
    if (full.length < 8) return full;
    return '${full.substring(0, full.length - 6)} *** '
        '${full.substring(full.length - 3)}';
  }
}
