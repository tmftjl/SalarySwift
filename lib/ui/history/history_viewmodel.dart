import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';
import 'package:salary_swift/data/repository/salary_repository.dart';

class HistoryState {
  final List<BatchSummary> batches;
  final bool isLoading;

  const HistoryState({this.batches = const [], this.isLoading = false});
}

class HistoryViewModel extends StateNotifier<HistoryState> {
  final SalaryRepository _repo;

  HistoryViewModel(this._repo) : super(const HistoryState()) {
    _load();
  }

  Future<void> _load() async {
    state = HistoryState(batches: state.batches, isLoading: true);
    final batches = await _repo.getBatchSummaries();
    state = HistoryState(batches: batches, isLoading: false);
  }

  Future<void> refresh() => _load();
}

final historyViewModelProvider =
    StateNotifierProvider<HistoryViewModel, HistoryState>((ref) {
  return HistoryViewModel(ref.watch(salaryRepositoryProvider));
});
