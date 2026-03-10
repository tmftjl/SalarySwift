import 'package:drift/drift.dart';

/// employees 表
class Employees extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
}
