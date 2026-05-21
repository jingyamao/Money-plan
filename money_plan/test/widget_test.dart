import 'package:flutter_test/flutter_test.dart';
import 'package:money_plan/main.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MoneyPlanApp());
    expect(find.text('Money Plan'), findsOneWidget);
  });
}
