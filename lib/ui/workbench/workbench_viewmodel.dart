import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/entity/employee.dart';
import 'package:salary_swift/data/repository/employee_repository.dart';
import 'package:salary_swift/data/repository/salary_repository.dart';

/// 工作台页面状态
class WorkbenchState {
  final List<Employee> pendingEmployees;   // 待录入
  final List<Employee> enteredEmployees;   // 已录入
  final Map<int, double> enteredAmounts;   // employeeId -> amount
  final bool isLoading;

  const WorkbenchState({
    this.pendingEmployees = const [],
    this.enteredEmployees = const [],
    this.enteredAmounts = const {},
    this.isLoading = false,
  });

  double get totalAmount =>
      enteredAmounts.values.fold(0.0, (sum, a) => sum + a);

  WorkbenchState copyWith({
    List<Employee>? pendingEmployees,
    List<Employee>? enteredEmployees,
    Map<int, double>? enteredAmounts,
    bool? isLoading,
  }) {
    return WorkbenchState(
      pendingEmployees: pendingEmployees ?? this.pendingEmployees,
      enteredEmployees: enteredEmployees ?? this.enteredEmployees,
      enteredAmounts: enteredAmounts ?? this.enteredAmounts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WorkbenchViewModel extends StateNotifier<WorkbenchState> {
  final EmployeeRepository _employeeRepo;
  final SalaryRepository _salaryRepo;

  WorkbenchViewModel(this._employeeRepo, this._salaryRepo)
      : super(const WorkbenchState()) {
    _init();
  }

  void _init() {
    // 监听在职员工变化
    _employeeRepo.watchActiveEmployees().listen((allEmployees) async {
      final activeRecords = await _salaryRepo.watchActiveRecords().first;
      final activeIds = activeRecords.map((r) => r.employeeId).toSet();
      
      final amounts = <int, double>{};
      for (final record in activeRecords) {
        amounts[record.employeeId] = record.amount;
      }

      state = state.copyWith(
        pendingEmployees: allEmployees.where((e) => !activeIds.contains(e.id)).toList(),
        enteredEmployees: allEmployees.where((e) => activeIds.contains(e.id)).toList(),
        enteredAmounts: amounts,
      );
    });
  }

  Future<void> _refresh() async {
    // 触发上面的监听器，不需要额外逻辑
  }

  /// 录入或更新某员工工资
  Future<void> saveAmount(int employeeId, double amount) async {
    await _salaryRepo.saveActiveRecord(employeeId, amount);
  }

  /// 撤回某员工的录入（使其回到待录入）
  Future<void> undoAmount(int employeeId) async {
    await _salaryRepo.deleteActiveRecord(employeeId);
  }

  /// 导入上月数据
  Future<void> importLastMonth() async {
    await _salaryRepo.importLastMonth();
  }

  /// 一键结算
  Future<void> settle() async {
    await _salaryRepo.settleCurrentMonth();
  }
}

final workbenchViewModelProvider =
    StateNotifierProvider<WorkbenchViewModel, WorkbenchState>((ref) {
  return WorkbenchViewModel(
    ref.watch(employeeRepositoryProvider),
    ref.watch(salaryRepositoryProvider),
  );
});
