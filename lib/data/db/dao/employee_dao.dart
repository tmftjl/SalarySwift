import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entity/employee.dart';

part 'employee_dao.g.dart';

@DriftAccessor(tables: [Employees])
class EmployeeDao extends DatabaseAccessor<AppDatabase>
    with _$EmployeeDaoMixin {
  EmployeeDao(super.db);

  /// 查询所有在职员工
  Stream<List<Employee>> watchActiveEmployees() {
    return (select(employees)
          ..where((e) => e.isActive.equals(1))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .watch();
  }

  /// 查询所有在职员工（一次性）
  Future<List<Employee>> getActiveEmployees() {
    return (select(employees)
          ..where((e) => e.isActive.equals(1))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .get();
  }

  /// 新增员工
  Future<int> insertEmployee(EmployeesCompanion entry) {
    return into(employees).insert(entry);
  }

  /// 更新员工姓名
  Future<bool> updateEmployee(Employee employee) {
    return update(employees).replace(employee);
  }

  /// 软删除员工（is_active = 0）
  Future<int> softDeleteEmployee(int id) {
    return (update(employees)..where((e) => e.id.equals(id)))
        .write(const EmployeesCompanion(isActive: Value(0)));
  }
}
