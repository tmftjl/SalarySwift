import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/database_provider.dart';
import 'package:salary_swift/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const SalarySwiftApp(),
      ),
    );
    expect(find.text('工作台'), findsOneWidget);
  });
}
