import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/database_provider.dart';
import 'package:salary_swift/data/repository/salary_repository.dart';

final employeeRepositoryProvider = Provider((ref) {
  return EmployeeRepository(
    ref.watch(databaseProvider),
    ref.watch(salaryRepositoryProvider),
  );
});

class EmployeeRepository {
  final AppDatabase _db;
  final SalaryRepository _salaryRepo;

  EmployeeRepository(this._db, this._salaryRepo);

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
    await _salaryRepo.deleteAllByEmployee(id);
    await _db.employeeDao.softDeleteEmployee(id);
  }
}

