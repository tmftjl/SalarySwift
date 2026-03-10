import 'package:drift/drift.dart';
import 'employee.dart';

/// salary_records 表
/// status: 'active'（当前周期）| 'settled'（已归档）
/// batch_key: 结算批次标识，格式 YYYY-MM，active 时为 NULL
class SalaryRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get employeeId => integer().references(Employees, #id)();
  RealColumn get amount => real()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get batchKey => text().nullable()();
  IntColumn get createdAt => integer()();
}
