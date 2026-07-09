import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fundi_connect/app.dart';

void main() {
  testWidgets('App renders onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FundiConnectApp()),
    );

    expect(find.text('Onboarding Screen'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
