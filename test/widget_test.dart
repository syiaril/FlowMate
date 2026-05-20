import 'package:flutter_test/flutter_test.dart';
import 'package:cima_mens/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlowMateApp());
  });
}
