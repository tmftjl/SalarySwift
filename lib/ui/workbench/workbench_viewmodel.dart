import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/repository/employee_repository.dart';
import 'package:salary_swift/data/repository/salary_repository.dart';

class WorkbenchState {
  final int selectedYear;
  final int selectedMonth;
  final List<Employee> employees;
  final Map<int, double> savedAmounts; // employeeId -> amount（已存入DB的）
  final Map<int, double> draftAmounts; // employeeId -> amount（未保存草稿）
  final bool isLoading;
  final bool isSaving;

  const WorkbenchState({
    required this.selectedYear,
    required this.selectedMonth,
    this.employees = const [],
    this.savedAmounts = const {},
    this.draftAmounts = const {},
    this.isLoading = false,
    this.isSaving = false,
  });

  double get totalAmount =>
      savedAmounts.values.fold(0.0, (sum, a) => sum + a);

  WorkbenchState copyWith({
    int? selectedYear,
    int? selectedMonth,
    List<Employee>? employees,
    Map<int, double>? savedAmounts,
    Map<int, double>? draftAmounts,
    bool? isLoading,
    bool? isSaving,
  }) {
    return WorkbenchState(
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      employees: employees ?? this.employees,
      savedAmounts: savedAmounts ?? this.savedAmounts,
      draftAmounts: draftAmounts ?? this.draftAmounts,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class WorkbenchViewModel extends StateNotifier<WorkbenchState> {
  final EmployeeRepository _employeeRepo;
  final SalaryRepository _salaryRepo;

  StreamSubscription<List<Employee>>? _employeeSubscription;
  StreamSubscription<Map<int, double>>? _amountsSubscription;

  WorkbenchViewModel(this._employeeRepo, this._salaryRepo)
      : super(WorkbenchState(
          selectedYear: DateTime.now().year,
          selectedMonth: DateTime.now().month,
          isLoading: true,
        )) {
    _init();
  }

  void _init() {
    _employeeSubscription =
        _employeeRepo.watchActiveEmployees().listen((employees) {
      final nextDrafts = <int, double>{};
      final nextSaved = <int, double>{};
      for (final employee in employees) {
        final id = employee.id;
        final saved = state.savedAmounts[id];
        if (saved != null) {
          nextSaved[id] = saved;
        }
        if (state.draftAmounts.containsKey(id)) {
          nextDrafts[id] = state.draftAmounts[id]!;
        } else if (saved != null) {
          nextDrafts[id] = saved;
        }
      }

      state = state.copyWith(
        employees: employees,
        savedAmounts: nextSaved,
        draftAmounts: nextDrafts,
      );
      if (!state.isLoading) return;
      _subscribeAmounts(state.selectedYear, state.selectedMonth);
    });
  }

  void _subscribeAmounts(int year, int month) {
    _amountsSubscription?.cancel();
    _amountsSubscription =
        _salaryRepo.watchAmountsForMonth(year, month).listen((amounts) {
      final nextDrafts = <int, double>{};
      for (final employee in state.employees) {
        final id = employee.id;
        final saved = amounts[id] ?? 0.0;
        final previousSaved = state.savedAmounts[id] ?? 0.0;
        final previousDraft = state.draftAmounts[id] ?? previousSaved;
        final hasPending =
            (previousDraft - previousSaved).abs() > 0.0001;

        nextDrafts[id] = state.isSaving || !hasPending ? saved : previousDraft;
      }

      state = state.copyWith(
        savedAmounts: amounts,
        draftAmounts: nextDrafts,
        isLoading: false,
      );
    });
  }

  /// 切换到指定年月（重新加载对应工资数据）
  Future<void> changeMonth(int year, int month) async {
    state = state.copyWith(
      selectedYear: year,
      selectedMonth: month,
      savedAmounts: const {},
      draftAmounts: const {},
      isLoading: true,
    );
    _subscribeAmounts(year, month);
  }

  void updateDraftAmount(int employeeId, double amount) {
    final nextDrafts = Map<int, double>.from(state.draftAmounts);
    nextDrafts[employeeId] = amount;
    state = state.copyWith(draftAmounts: nextDrafts);
  }

  /// 切换到上一个月
  Future<void> prevMonth() async {
    int y = state.selectedYear;
    int m = state.selectedMonth - 1;
    if (m < 1) {
      m = 12;
      y--;
    }
    await changeMonth(y, m);
  }

  /// 切换到下一个月
  Future<void> nextMonth() async {
    int y = state.selectedYear;
    int m = state.selectedMonth + 1;
    if (m > 12) {
      m = 1;
      y++;
    }
    await changeMonth(y, m);
  }

  /// 批量保存当月工资（amount>0 则 upsert，否则 delete）
  Future<void> saveAll(Map<int, double> amounts) async {
    final year = state.selectedYear;
    final month = state.selectedMonth;
    state = state.copyWith(isSaving: true);
    try {
      await _salaryRepo.saveMonthAmounts(year, month, amounts);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  @override
  void dispose() {
    _employeeSubscription?.cancel();
    _amountsSubscription?.cancel();
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
