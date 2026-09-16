import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malta_wash/Src/Features/public/presentation/pages/responsive_home_page.dart';

void main() {
  testWidgets('public home exposes exactly the two official access buttons',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveHomePage(),
      ),
    );

    expect(find.text('Entrar como cliente'), findsOneWidget);
    expect(find.text('Entrar como empresa'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });
}
