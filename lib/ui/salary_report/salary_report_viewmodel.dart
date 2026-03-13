import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/repository/batch_repository.dart';
import 'package:salary_swift/data/repository/salary_repository.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';

class SalaryReportState {
  final List<SalaryBatch> batches;
  final bool isLoading;

  const SalaryReportState({this.batches = const [], this.isLoading = false});
}

class SalaryReportViewModel extends StateNotifier<SalaryReportState> {
  final BatchRepository _batchRepo;
  final SalaryRepository _salaryRepo;

  SalaryReportViewModel(this._batchRepo, this._salaryRepo)
      : super(const SalaryReportState(isLoading: true)) {
    _batchRepo.watchBatches().listen((batches) {
      state = SalaryReportState(batches: batches, isLoading: false);
    });
  }

  Future<BatchCreationError?> createBatch(
      int startYear, int startMonth, int endYear, int endMonth) async {
    return _batchRepo.insertBatch(startYear, startMonth, endYear, endMonth);
  }

  Future<void> deleteBatch(int id) => _batchRepo.deleteBatch(id);

  Future<List<SalaryDetailItem>> getDetailForBatch(SalaryBatch batch) =>
      _salaryRepo.getDetailForRange(
          batch.startYear, batch.startMonth, batch.endYear, batch.endMonth);
}

final salaryReportViewModelProvider =
    StateNotifierProvider<SalaryReportViewModel, SalaryReportState>((ref) {
  return SalaryReportViewModel(
    ref.watch(batchRepositoryProvider),
    ref.watch(salaryRepositoryProvider),
  );
});
