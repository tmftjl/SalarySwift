import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';
import 'package:salary_swift/data/repository/salary_repository.dart';

class HistoryState {
  final List<MonthSummary> months;
  final bool isLoading;

  const HistoryState({this.months = const [], this.isLoading = false});
}

class HistoryViewModel extends StateNotifier<HistoryState> {
  final SalaryRepository _repo;
  StreamSubscription<List<MonthSummary>>? _subscription;

  HistoryViewModel(this._repo) : super(const HistoryState(isLoading: true)) {
    _watch();
  }

  void _watch() {
    _subscription = _repo.watchMonthSummaries().listen((months) {
      state = HistoryState(months: months, isLoading: false);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final historyViewModelProvider =
    StateNotifierProvider.autoDispose<HistoryViewModel, HistoryState>((ref) {
  return HistoryViewModel(ref.watch(salaryRepositoryProvider));
});
