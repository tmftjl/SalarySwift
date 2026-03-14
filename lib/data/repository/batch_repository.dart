import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/database_provider.dart';

enum BatchCreationError {
  invalidRange,
  duplicateRange,
  tooManyMonths,
}

final batchRepositoryProvider = Provider((ref) {
  return BatchRepository(ref.watch(databaseProvider));
});

class BatchRepository {
  final AppDatabase _db;

  BatchRepository(this._db);

  /// 监听批次列表（按创建时间倒序）
  Stream<List<SalaryBatch>> watchBatches() => _db.batchDao.watchBatches();

  /// 新增结算批次
  Future<BatchCreationError?> insertBatch(
      int startYear, int startMonth, int endYear, int endMonth) async {
    final startPeriod = startYear * 100 + startMonth;
    final endPeriod = endYear * 100 + endMonth;
    if (startPeriod > endPeriod) {
      return BatchCreationError.invalidRange;
    }

    final monthCount =
        (endYear - startYear) * 12 + (endMonth - startMonth) + 1;
    if (monthCount > 12) {
      return BatchCreationError.tooManyMonths;
    }

    final exists = await _db.batchDao
        .existsBatchRange(startYear, startMonth, endYear, endMonth);
    if (exists) {
      return BatchCreationError.duplicateRange;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.batchDao.insertBatch(
      BatchesCompanion.insert(
        startYear: startYear,
        startMonth: startMonth,
        endYear: endYear,
        endMonth: endMonth,
        createdAt: now,
      ),
    );
    return null;
  }

  /// 删除批次
  Future<void> deleteBatch(int id) => _db.batchDao.deleteBatch(id);
}
