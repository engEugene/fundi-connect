import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fundi_connect/app.dart';
import 'package:fundi_connect/features/auth/providers/auth_provider.dart';

void main() {
  setUpAll(() {
    // stops google fonts from trying to download in test
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('app boots into the onboarding flow', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _TestAuthNotifier()),
        ],
        child: const FundiConnectApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(initializing: false);
}
