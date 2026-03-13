import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/repository/employee_repository.dart';

final employeesViewModelProvider =
    StateNotifierProvider.autoDispose<EmployeesViewModel, AsyncValue<List<Employee>>>((ref) {
  return EmployeesViewModel(ref.watch(employeeRepositoryProvider));
});

class EmployeesViewModel extends StateNotifier<AsyncValue<List<Employee>>> {
  final EmployeeRepository _repo;
  StreamSubscription<List<Employee>>? _subscription;

  EmployeesViewModel(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription = _repo.watchActiveEmployees().listen((list) {
      state = AsyncValue.data(list);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addEmployee(String name) => _repo.addEmployee(name.trim());

  Future<void> updateName(Employee employee, String newName) =>
      _repo.updateEmployeeName(employee, newName.trim());

  Future<void> deleteEmployee(int id) => _repo.deleteEmployee(id);
}
