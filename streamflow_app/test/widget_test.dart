import 'package:flutter_test/flutter_test.dart';

import 'package:streamflow/main.dart';

void main() {
  testWidgets('StreamFlow app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StreamFlowApp());

    // Verify that StreamFlow title is present
    expect(find.text('StreamFlow'), findsOneWidget);
    expect(find.text('Premium OLED Anime Streaming'), findsOneWidget);
    
    // Verify "GET STARTED" button is present
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
