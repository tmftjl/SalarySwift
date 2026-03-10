import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'entity/employee.dart';
import 'entity/salary_record.dart';
import 'dao/employee_dao.dart';
import 'dao/salary_record_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Employees, SalaryRecords],
  daos: [EmployeeDao, SalaryRecordDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'salary_swift.db'));
    return NativeDatabase.createInBackground(file);
  });
}
