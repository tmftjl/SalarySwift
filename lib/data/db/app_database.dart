import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'entity/employee.dart';
import 'entity/salary_record.dart';
import 'entity/batch.dart';
import 'dao/employee_dao.dart';
import 'dao/salary_record_dao.dart';
import 'dao/batch_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Employees, SalaryRecords, Batches],
  daos: [EmployeeDao, SalaryRecordDao, BatchDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1 的 salary_records 结构已完全改变，直接重建
            await customStatement('DROP TABLE IF EXISTS salary_records');
            await m.createTable(salaryRecords);
            await m.createTable(batches);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'salary_swift.db'));
    return NativeDatabase.createInBackground(file);
  });
}
