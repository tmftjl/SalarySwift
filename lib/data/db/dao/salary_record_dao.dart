import 'package:drift/drift.dart';
import '../app_database.dart';
import '../entity/employee.dart';
import '../entity/salary_record.dart';

part 'salary_record_dao.g.dart';

/// 批次汇总信息（用于历史列表）
class BatchSummary {
  final String batchKey;
  final double totalAmount;
  final int employeeCount;

  BatchSummary({
    required this.batchKey,
    required this.totalAmount,
    required this.employeeCount,
  });
}

/// 批次明细条目（用于历史详情 & PDF）
class BatchDetailItem {
  final int employeeId;
  final String employeeName;
  final double amount;

  BatchDetailItem({
    required this.employeeId,
    required this.employeeName,
    required this.amount,
  });
}

@DriftAccessor(tables: [SalaryRecords, Employees])
class SalaryRecordDao extends DatabaseAccessor<AppDatabase>
    with _$SalaryRecordDaoMixin {
  SalaryRecordDao(super.db);

  // ── 工作台 ──────────────────────────────────────────────

  /// 监听当前所有 active 记录（含员工姓名）
  Stream<List<BatchDetailItem>> watchActiveRecords() {
    final query = select(salaryRecords).join([
      innerJoin(employees, employees.id.equalsExp(salaryRecords.employeeId)),
    ])
      ..where(salaryRecords.status.equals('active'));

    return query.watch().map((rows) => rows.map((row) {
          return BatchDetailItem(
            employeeId: row.readTable(employees).id,
            employeeName: row.readTable(employees).name,
            amount: row.readTable(salaryRecords).amount,
          );
        }).toList());
  }

  /// 获取当前 active 记录的员工ID集合
  Future<Set<int>> getActiveEmployeeIds() async {
    final rows = await (select(salaryRecords)
          ..where((r) => r.status.equals('active')))
        .get();
    return rows.map((r) => r.employeeId).toSet();
  }

  /// 插入或更新 active 记录
  Future<int> upsertActiveRecord(SalaryRecordsCompanion entry) {
    return into(salaryRecords).insertOnConflictUpdate(entry);
  }

  /// 删除某员工的 active 记录（用于撤销录入）
  Future<int> deleteActiveRecord(int employeeId) {
    return (delete(salaryRecords)
          ..where((r) =>
              r.employeeId.equals(employeeId) & r.status.equals('active')))
        .go();
  }

  // ── 结算 ──────────────────────────────────────────────

  /// 将所有 active 记录归档（一键结算）
  Future<void> settleAll(String batchKey) {
    return (update(salaryRecords)..where((r) => r.status.equals('active')))
        .write(SalaryRecordsCompanion(
      status: const Value('settled'),
      batchKey: Value(batchKey),
    ));
  }

  // ── 历史记录 ──────────────────────────────────────────

  /// 获取历史批次列表（按 batch_key 倒序）
  Future<List<BatchSummary>> getBatchSummaries() async {
    final query = customSelect(
      '''
      SELECT batch_key,
             SUM(amount)  AS total_amount,
             COUNT(*)     AS employee_count
      FROM salary_records
      WHERE status = 'settled'
      GROUP BY batch_key
      ORDER BY batch_key DESC
      ''',
      readsFrom: {salaryRecords},
    );
    final rows = await query.get();
    return rows.map((row) {
      return BatchSummary(
        batchKey: row.read<String>('batch_key'),
        totalAmount: row.read<double>('total_amount'),
        employeeCount: row.read<int>('employee_count'),
      );
    }).toList();
  }

  /// 获取某批次的明细列表
  Future<List<BatchDetailItem>> getBatchDetail(String batchKey) async {
    final query = select(salaryRecords).join([
      innerJoin(employees, employees.id.equalsExp(salaryRecords.employeeId)),
    ])
      ..where(salaryRecords.batchKey.equals(batchKey));

    final rows = await query.get();
    return rows.map((row) {
      return BatchDetailItem(
        employeeId: row.readTable(employees).id,
        employeeName: row.readTable(employees).name,
        amount: row.readTable(salaryRecords).amount,
      );
    }).toList();
  }

  // ── 导入上月 ──────────────────────────────────────────

  /// 获取最近一个 settled 批次的 batch_key
  Future<String?> getLastBatchKey() async {
    final row = await (select(salaryRecords)
          ..where((r) => r.status.equals('settled'))
          ..orderBy([(r) => OrderingTerm.desc(r.batchKey)])
          ..limit(1))
        .getSingleOrNull();
    return row?.batchKey;
  }

  /// 获取指定批次的所有记录
  Future<List<SalaryRecord>> getRecordsByBatch(String batchKey) {
    return (select(salaryRecords)
          ..where((r) => r.batchKey.equals(batchKey)))
        .get();
  }
}
