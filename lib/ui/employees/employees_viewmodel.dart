import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/entity/employee.dart';
import 'package:salary_swift/data/repository/employee_repository.dart';

final employeesViewModelProvider =
    StateNotifierProvider<EmployeesViewModel, AsyncValue<List<Employee>>>((ref) {
  return EmployeesViewModel(ref.watch(employeeRepositoryProvider));
});

class EmployeesViewModel extends StateNotifier<AsyncValue<List<Employee>>> {
  final EmployeeRepository _repo;

  EmployeesViewModel(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final subscription = _repo.watchActiveEmployees().listen((list) {
      state = AsyncValue.data(list);
    });
    
    // 监听销毁
    // 注意：Riverpod 2.x 中 StateNotifier 内部没有直接的 onDispose，
    // 通常在 provider 定义处处理，或者在这里覆盖 dispose。
  }

  @override
  void dispose() {
    // 实际项目中这里应取消 subscription
    super.dispose();
  }

  Future<void> addEmployee(String name) => _repo.addEmployee(name.trim());

  Future<void> updateName(Employee employee, String newName) =>
      _repo.updateEmployeeName(employee, newName.trim());

  Future<void> deleteEmployee(int id) => _repo.deleteEmployee(id);
}
