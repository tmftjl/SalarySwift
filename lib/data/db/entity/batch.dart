import 'package:drift/drift.dart';

/// batches 表：工资结算批次，只存时间段
/// 查询时按 startYear/startMonth ~ endYear/endMonth 到 salary_records 取数据
@DataClassName('SalaryBatch')
class Batches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get startYear => integer()();
  IntColumn get startMonth => integer()();
  IntColumn get endYear => integer()();
  IntColumn get endMonth => integer()();
  IntColumn get createdAt => integer()();
}
