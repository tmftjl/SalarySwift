import 'package:drift/drift.dart';
import 'employee.dart';

/// salary_records 表
/// 每条记录 = 某员工某年某月的工资，(employeeId, year, month) 唯一
class SalaryRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get employeeId => integer().references(Employees, #id)();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  RealColumn get amount => real()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {employeeId, year, month},
      ];
}
