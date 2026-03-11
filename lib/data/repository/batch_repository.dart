import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/database_provider.dart';

final batchRepositoryProvider = Provider((ref) {
  return BatchRepository(ref.watch(databaseProvider));
});

class BatchRepository {
  final AppDatabase _db;

  BatchRepository(this._db);

  /// 监听批次列表（按创建时间倒序）
  Stream<List<SalaryBatch>> watchBatches() => _db.batchDao.watchBatches();

  /// 新增结算批次
  Future<void> insertBatch(
      int startYear, int startMonth, int endYear, int endMonth) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.batchDao.insertBatch(
      BatchesCompanion.insert(
        startYear: startYear,
        startMonth: startMonth,
        endYear: endYear,
        endMonth: endMonth,
        createdAt: now,
      ),
    );
  }

  /// 删除批次
  Future<void> deleteBatch(int id) => _db.batchDao.deleteBatch(id);
}
