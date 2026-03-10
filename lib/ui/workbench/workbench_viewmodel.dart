import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';
import 'package:salary_swift/data/db/app_database.dart';
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
  StreamSubscription<List<Employee>>? _employeeSubscription;
  StreamSubscription<List<BatchDetailItem>>? _activeRecordSubscription;
  List<Employee> _allEmployees = const [];
  List<BatchDetailItem> _activeRecords = const [];
  bool _hasEmployeeSnapshot = false;
  bool _hasActiveRecordSnapshot = false;

  WorkbenchViewModel(this._employeeRepo, this._salaryRepo)
      : super(const WorkbenchState(isLoading: true)) {
    _init();
  }

  void _init() {
    _employeeSubscription = _employeeRepo.watchActiveEmployees().listen((allEmployees) {
      _allEmployees = allEmployees;
      _hasEmployeeSnapshot = true;
      _rebuildState();
    });

    _activeRecordSubscription = _salaryRepo.watchActiveRecords().listen((activeRecords) {
      _activeRecords = activeRecords;
      _hasActiveRecordSnapshot = true;
      _rebuildState();
    });
  }

  void _rebuildState() {
    if (!_hasEmployeeSnapshot || !_hasActiveRecordSnapshot) {
      return;
    }

    final activeIds = _activeRecords.map((record) => record.employeeId).toSet();
    final amounts = <int, double>{
      for (final record in _activeRecords) record.employeeId: record.amount,
    };
    final enteredEmployees =
        _allEmployees.where((employee) => activeIds.contains(employee.id)).toList();
    final pendingEmployees =
        _allEmployees.where((employee) => !activeIds.contains(employee.id)).toList();

    state = state.copyWith(
      pendingEmployees: pendingEmployees,
      enteredEmployees: enteredEmployees,
      enteredAmounts: amounts,
      isLoading: false,
    );
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

  @override
  void dispose() {
    _employeeSubscription?.cancel();
    _activeRecordSubscription?.cancel();
    super.dispose();
  }
}

final workbenchViewModelProvider =
    StateNotifierProvider<WorkbenchViewModel, WorkbenchState>((ref) {
  return WorkbenchViewModel(
    ref.watch(employeeRepositoryProvider),
    ref.watch(salaryRepositoryProvider),
  );
});
