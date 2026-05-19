import 'package:flutter_test/flutter_test.dart';
import 'package:smart_sakhi_app/main.dart';

void main() {
  testWidgets('Sakhi Rakshak App boot test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartSakhiApp());

    // Verify that the splash screen shows the App Name
    expect(find.text('Sakhi Rakshak'), findsOneWidget);

    // Settle the splash screen delayed transition timer without waiting for infinite animations
    await tester.pump(const Duration(seconds: 3));
  });
}
