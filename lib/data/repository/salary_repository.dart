import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';
import 'package:salary_swift/data/db/entity/salary_record.dart';

final salaryRepositoryProvider = Provider((ref) {
  return SalaryRepository(ref.watch(databaseProvider));
});

class SalaryRepository {
  final AppDatabase _db;

  SalaryRepository(this._db);

  Stream<List<BatchDetailItem>> watchActiveRecords() =>
      _db.salaryRecordDao.watchActiveRecords();

  Future<Set<int>> getActiveEmployeeIds() =>
      _db.salaryRecordDao.getActiveEmployeeIds();

  /// 保存或更新某员工的 active 工资记录
  Future<void> saveActiveRecord(int employeeId, double amount) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.salaryRecordDao.upsertActiveRecord(
      SalaryRecordsCompanion.insert(
        employeeId: employeeId,
        amount: amount,
        createdAt: now,
      ),
    );
  }

  Future<void> deleteActiveRecord(int employeeId) =>
      _db.salaryRecordDao.deleteActiveRecord(employeeId);

  /// 一键结算：将所有 active 记录归档到当前月批次
  Future<void> settleCurrentMonth() {
    final now = DateTime.now();
    final batchKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _db.salaryRecordDao.settleAll(batchKey);
  }

  Future<List<BatchSummary>> getBatchSummaries() =>
      _db.salaryRecordDao.getBatchSummaries();

  Future<List<BatchDetailItem>> getBatchDetail(String batchKey) =>
      _db.salaryRecordDao.getBatchDetail(batchKey);

  /// 导入上月：复制最近批次的记录为新 active 记录
  Future<void> importLastMonth() async {
    final lastBatchKey = await _db.salaryRecordDao.getLastBatchKey();
    if (lastBatchKey == null) return;

    final lastRecords =
        await _db.salaryRecordDao.getRecordsByBatch(lastBatchKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final record in lastRecords) {
      await _db.salaryRecordDao.upsertActiveRecord(
        SalaryRecordsCompanion.insert(
          employeeId: record.employeeId,
          amount: record.amount,
          createdAt: now,
        ),
      );
    }
  }
}
