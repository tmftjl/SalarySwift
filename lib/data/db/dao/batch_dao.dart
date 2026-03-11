import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entity/batch.dart';

part 'batch_dao.g.dart';

@DriftAccessor(tables: [Batches])
class BatchDao extends DatabaseAccessor<AppDatabase> with _$BatchDaoMixin {
  BatchDao(super.db);

  /// 新增一个结算批次
  Future<void> insertBatch(BatchesCompanion entry) =>
      into(batches).insert(entry);

  /// 监听批次列表（按创建时间倒序）
  Stream<List<SalaryBatch>> watchBatches() => (select(batches)
        ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
      .watch();

  /// 删除批次
  Future<void> deleteBatch(int id) =>
      (delete(batches)..where((b) => b.id.equals(id))).go();
}
