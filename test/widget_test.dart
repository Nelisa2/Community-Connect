import 'package:flutter_test/flutter_test.dart';
import 'package:community_connect/main.dart';

void main() {
  testWidgets('Community Connect welcome screen test',
      (WidgetTester tester) async {
    // Build our Community Connect app.
    await tester.pumpWidget(const CommunityConnectApp());

    // Check that the welcome message appears.
    expect(find.text('Welcome to Community Connect'), findsOneWidget);

    // Check that the Get Started button appears.
    expect(find.text('Get Started'), findsOneWidget);
  });
}