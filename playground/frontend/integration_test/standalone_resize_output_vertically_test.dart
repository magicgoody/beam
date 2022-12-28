import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:playground_components_dev/playground_components_dev.dart';

import 'common/common.dart';
import 'common/common_finders.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Resizes vertically as expected', (WidgetTester wt) async {
    await init(wt);

    expect(find.dragHandle(), findsOneWidget);

    final height = wt.getSize(find.splitView()).height;
    final dragHandlePosition = wt.getCenter(find.dragHandle());

    await wt.drag(find.dragHandle(), Offset(0, height * 0.1));
    await wt.pumpAndSettle();

    final newPosition = wt.getCenter(find.dragHandle());
    expectSimilar(newPosition.dy, dragHandlePosition.dy + height * 0.1);
  });
}
