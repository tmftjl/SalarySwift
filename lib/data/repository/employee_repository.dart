import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/database_provider.dart';
import 'package:salary_swift/data/db/entity/employee.dart';

final employeeRepositoryProvider = Provider((ref) {
  return EmployeeRepository(ref.watch(databaseProvider));
});

class EmployeeRepository {
  final AppDatabase _db;

  EmployeeRepository(this._db);

  Stream<List<Employee>> watchActiveEmployees() =>
      _db.employeeDao.watchActiveEmployees();

  Future<List<Employee>> getActiveEmployees() =>
      _db.employeeDao.getActiveEmployees();

  Future<void> addEmployee(String name) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.employeeDao.insertEmployee(
      EmployeesCompanion.insert(name: name, createdAt: now),
    );
  }

  Future<void> updateEmployeeName(Employee employee, String newName) {
    return _db.employeeDao.updateEmployee(employee.copyWith(name: newName));
  }

  Future<void> deleteEmployee(int id) async {
    await _db.salaryRecordDao.deleteActiveRecord(id);
    await _db.employeeDao.softDeleteEmployee(id);
  }
}
