import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_ninja_frontend/main.dart';

void main() {
  testWidgets('FruitNinjaGameApp renders main menu', (WidgetTester tester) async {
    await tester.pumpWidget(const FruitNinjaGameApp());
    expect(find.text('Fruit Ninja Arcade'), findsOneWidget);
  });
}
