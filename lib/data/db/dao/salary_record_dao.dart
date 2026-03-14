import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entity/employee.dart';
import '../entity/salary_record.dart';

part 'salary_record_dao.g.dart';

/// 月份汇总（用于历史记录列表）
class MonthSummary {
  final int year;
  final int month;
  final double totalAmount;
  final int employeeCount;

  MonthSummary({
    required this.year,
    required this.month,
    required this.totalAmount,
    required this.employeeCount,
  });
}

/// 单条工资明细（含所属年月，跨月报表时使用）
class SalaryDetailItem {
  final int employeeId;
  final String employeeName;
  final int year;
  final int month;
  final double amount;

  SalaryDetailItem({
    required this.employeeId,
    required this.employeeName,
    required this.year,
    required this.month,
    required this.amount,
  });
}

@DriftAccessor(tables: [SalaryRecords, Employees])
class SalaryRecordDao extends DatabaseAccessor<AppDatabase>
    with _$SalaryRecordDaoMixin {
  SalaryRecordDao(super.db);

  double _fromCents(int cents) => cents / 100.0;

  int _toCents(double amount) => (amount * 100).round();

  // ── 工作台：按年月读写 ────────────────────────────────

  /// 监听某年月的 employeeId -> amount 映射
  Stream<Map<int, double>> watchAmountsForMonth(int year, int month) {
    return (select(salaryRecords)
          ..where((r) => r.year.equals(year) & r.month.equals(month)))
        .watch()
        .map((rows) => {
              for (final r in rows) r.employeeId: _fromCents(r.amount),
            });
  }

  /// 一次性获取某年月的 employeeId -> amount 映射
  Future<Map<int, double>> getAmountsForMonth(int year, int month) async {
    final rows = await (select(salaryRecords)
          ..where((r) => r.year.equals(year) & r.month.equals(month)))
        .get();
    return {
      for (final r in rows) r.employeeId: _fromCents(r.amount),
    };
  }

  /// 插入或覆盖某员工某月工资（依赖唯一约束 employeeId+year+month）
  Future<void> upsertRecord(
      int employeeId, int year, int month, double amount) async {
    await into(salaryRecords).insert(
      SalaryRecordsCompanion.insert(
        employeeId: employeeId,
        year: year,
        month: month,
        amount: _toCents(amount),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// 删除某员工某月工资
  Future<void> deleteRecord(int employeeId, int year, int month) async {
    await (delete(salaryRecords)
          ..where((r) =>
              r.employeeId.equals(employeeId) &
              r.year.equals(year) &
              r.month.equals(month)))
        .go();
  }

  /// 删除某员工的所有工资记录（员工被删除时调用）
  Future<void> deleteAllByEmployee(int employeeId) async {
    await (delete(salaryRecords)
          ..where((r) => r.employeeId.equals(employeeId)))
        .go();
  }

  // ── 历史记录：按月汇总 ────────────────────────────────

  /// 监听所有有数据的年月列表（倒序）
  Stream<List<MonthSummary>> watchMonthSummaries() {
    final query = customSelect(
      '''
      SELECT year, month,
             SUM(amount) / 100.0 AS total_amount,
             COUNT(*)     AS employee_count
      FROM salary_records
      GROUP BY year, month
      ORDER BY year DESC, month DESC
      ''',
      readsFrom: {salaryRecords},
    );
    return query.watch().map((rows) => rows
        .map((r) => MonthSummary(
              year: r.read<int>('year'),
              month: r.read<int>('month'),
              totalAmount: r.read<double>('total_amount'),
              employeeCount: r.read<int>('employee_count'),
            ))
        .toList());
  }

  /// 获取某年月的员工工资明细
  Future<List<SalaryDetailItem>> getDetailForMonth(int year, int month) async {
    final query = customSelect(
      '''
      SELECT e.id AS employee_id, e.name AS employee_name,
             sr.year, sr.month, sr.amount / 100.0 AS amount
      FROM salary_records sr
      INNER JOIN employees e ON e.id = sr.employee_id
      WHERE sr.year = ? AND sr.month = ?
      ORDER BY e.created_at
      ''',
      variables: [Variable.withInt(year), Variable.withInt(month)],
      readsFrom: {salaryRecords, employees},
    );
    final rows = await query.get();
    return rows
        .map((r) => SalaryDetailItem(
              employeeId: r.read<int>('employee_id'),
              employeeName: r.read<String>('employee_name'),
              year: year,
              month: month,
              amount: r.read<double>('amount'),
            ))
        .toList();
  }

  // ── 批次报表：按时间范围查询 ─────────────────────────

  /// 获取指定起止年月范围内所有工资明细（用于跨月报表导出）
  Future<List<SalaryDetailItem>> getDetailForRange(
      int startYear, int startMonth, int endYear, int endMonth) async {
    final startPeriod = startYear * 100 + startMonth;
    final endPeriod = endYear * 100 + endMonth;

    final query = customSelect(
      '''
      SELECT e.id AS employee_id, e.name AS employee_name,
             sr.year, sr.month, sr.amount / 100.0 AS amount
      FROM salary_records sr
      INNER JOIN employees e ON e.id = sr.employee_id
      WHERE sr.year * 100 + sr.month BETWEEN ? AND ?
      ORDER BY sr.year, sr.month, e.created_at
      ''',
      variables: [
        Variable.withInt(startPeriod),
        Variable.withInt(endPeriod),
      ],
      readsFrom: {salaryRecords, employees},
    );
    final rows = await query.get();
    return rows
        .map((r) => SalaryDetailItem(
              employeeId: r.read<int>('employee_id'),
              employeeName: r.read<String>('employee_name'),
              year: r.read<int>('year'),
              month: r.read<int>('month'),
              amount: r.read<double>('amount'),
            ))
        .toList();
  }
}
