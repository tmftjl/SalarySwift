import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/database_provider.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';

final salaryRepositoryProvider = Provider((ref) {
  return SalaryRepository(ref.watch(databaseProvider));
});

class SalaryRepository {
  final AppDatabase _db;

  SalaryRepository(this._db);

  // ── 工作台 ──────────────────────────────────────────

  /// 监听某年月的工资映射 employeeId -> amount
  Stream<Map<int, double>> watchAmountsForMonth(int year, int month) =>
      _db.salaryRecordDao.watchAmountsForMonth(year, month);

  /// 一次性获取某年月的工资映射
  Future<Map<int, double>> getAmountsForMonth(int year, int month) =>
      _db.salaryRecordDao.getAmountsForMonth(year, month);

  /// 保存（插入或覆盖）某员工某月工资
  Future<void> upsertRecord(
          int employeeId, int year, int month, double amount) =>
      _db.salaryRecordDao.upsertRecord(employeeId, year, month, amount);

  /// 删除某员工某月工资
  Future<void> deleteRecord(int employeeId, int year, int month) =>
      _db.salaryRecordDao.deleteRecord(employeeId, year, month);

  /// 删除某员工的所有工资记录
  Future<void> deleteAllByEmployee(int employeeId) =>
      _db.salaryRecordDao.deleteAllByEmployee(employeeId);

  // ── 历史记录 ────────────────────────────────────────

  /// 监听所有月份汇总列表
  Stream<List<MonthSummary>> watchMonthSummaries() =>
      _db.salaryRecordDao.watchMonthSummaries();

  /// 获取某年月明细
  Future<List<SalaryDetailItem>> getDetailForMonth(int year, int month) =>
      _db.salaryRecordDao.getDetailForMonth(year, month);

  // ── 批次报表 ─────────────────────────────────────────

  /// 获取指定时间范围内所有工资明细
  Future<List<SalaryDetailItem>> getDetailForRange(
          int startYear, int startMonth, int endYear, int endMonth) =>
      _db.salaryRecordDao
          .getDetailForRange(startYear, startMonth, endYear, endMonth);
}
