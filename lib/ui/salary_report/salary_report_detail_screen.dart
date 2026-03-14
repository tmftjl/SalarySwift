import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';
import 'package:salary_swift/data/repository/salary_repository.dart';
import 'package:salary_swift/util/pdf_exporter.dart';

import 'salary_report_viewmodel.dart';

final _batchDetailProvider = FutureProvider.autoDispose
    .family<List<SalaryDetailItem>, SalaryBatch>((ref, batch) {
  return ref.watch(salaryRepositoryProvider).getDetailForRange(
        batch.startYear,
        batch.startMonth,
        batch.endYear,
        batch.endMonth,
      );
});

class SalaryReportDetailScreen extends ConsumerWidget {
  const SalaryReportDetailScreen({super.key, required this.batch});

  final SalaryBatch batch;

  String _batchLabel(SalaryBatch b) {
    final start = '${b.startYear}年${b.startMonth}月';
    final end = '${b.endYear}年${b.endMonth}月';
    return start == end ? start : '$start - $end';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_batchDetailProvider(batch));

    return Scaffold(
      appBar: AppBar(
        title: Text(_batchLabel(batch)),
        actions: [
          IconButton(
            onPressed: () => _exportBatch(context, ref),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: '导出报表',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载报表失败：$e')),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyBatchData();
          }
          return _ReportPreview(batch: batch, items: items);
        },
      ),
    );
  }

  Future<void> _exportBatch(BuildContext context, WidgetRef ref) async {
    try {
      final items = await ref
          .read(salaryReportViewModelProvider.notifier)
          .getDetailForBatch(batch);
      if (items.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('该批次范围内暂无工资数据'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      await PdfExporter.exportSalaryReport(batch: batch, items: items);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败：$e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _ReportPreview extends StatelessWidget {
  const _ReportPreview({
    required this.batch,
    required this.items,
  });

  final SalaryBatch batch;
  final List<SalaryDetailItem> items;

  static const _colName = 100.0;
  static const _colMonth = 105.0;
  static const _colTotal = 110.0;

  static const _headerBg = Color(0xFF1565C0);
  static const _totalRowBg = Color(0xFFE8F1FF);
  static const _borderColor = Color(0xFFCDD8F0);
  static const _altRowBg = Color(0xFFF7FAFF);

  @override
  Widget build(BuildContext context) {
    final data = _ReportMatrix.fromItems(items);
    final fmt = NumberFormat('#,##0.00', 'zh_CN');
    final tableWidth =
        _colName + data.months.length * _colMonth + _colTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 表格
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border:
                    const Border.fromBorderSide(BorderSide(color: _borderColor)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 表头
                        _ReportRow(
                          backgroundColor: _headerBg,
                          cells: [
                            const _ReportCell('姓名',
                                width: _colName, isHeader: true),
                            ...data.months.map(
                              (month) => _ReportCell(
                                _fmtMonthKey(month),
                                width: _colMonth,
                                isHeader: true,
                                align: TextAlign.center,
                              ),
                            ),
                            const _ReportCell('合计',
                                width: _colTotal,
                                align: TextAlign.right,
                                isHeader: true),
                          ],
                        ),
                        // 数据行
                        ...data.employeeNames.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final name = entry.value;
                          var total = 0.0;
                          final cells = <_ReportCell>[
                            _ReportCell(name, width: _colName),
                          ];
                          for (final month in data.months) {
                            final amount = data.lookup[month]?[name] ?? 0.0;
                            total += amount;
                            cells.add(
                              _ReportCell(
                                amount > 0 ? fmt.format(amount) : '–',
                                width: _colMonth,
                                align: TextAlign.right,
                                dimmed: amount == 0,
                              ),
                            );
                          }
                          cells.add(
                            _ReportCell(
                              fmt.format(total),
                              width: _colTotal,
                              align: TextAlign.right,
                              isStrong: true,
                            ),
                          );
                          return _ReportRow(
                            backgroundColor:
                                idx.isOdd ? _altRowBg : Colors.white,
                            cells: cells,
                          );
                        }),
                        // 合计行
                        _ReportRow(
                          backgroundColor: _totalRowBg,
                          cells: [
                            const _ReportCell('合计',
                                width: _colName, isStrong: true),
                            ...data.months.map(
                              (month) => _ReportCell(
                                fmt.format(data.columnTotal(month)),
                                width: _colMonth,
                                align: TextAlign.right,
                                isStrong: true,
                              ),
                            ),
                            _ReportCell(
                              fmt.format(data.grandTotal),
                              width: _colTotal,
                              align: TextAlign.right,
                              isStrong: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmtMonthKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return key;
    return '${int.tryParse(parts[1]) ?? parts[1]}月';
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.cells,
    this.backgroundColor,
  });

  final List<_ReportCell> cells;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor),
      child: Row(children: cells),
    );
  }
}

class _ReportCell extends StatelessWidget {
  const _ReportCell(
    this.text, {
    required this.width,
    this.align = TextAlign.left,
    this.isHeader = false,
    this.isStrong = false,
    this.dimmed = false,
  });

  final String text;
  final double width;
  final TextAlign align;
  final bool isHeader;
  final bool isStrong;
  final bool dimmed;

  static const _border = BorderSide(color: Color(0xFFCDD8F0), width: 0.8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(
          right: _border,
          bottom: _border,
        ),
      ),
      alignment: align == TextAlign.right
          ? Alignment.centerRight
          : align == TextAlign.center
              ? Alignment.center
              : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 12 : 12,
          fontWeight: isHeader || isStrong ? FontWeight.w700 : FontWeight.w400,
          color: isHeader
              ? Colors.white
              : dimmed
                  ? const Color(0xFFBBC5D6)
                  : isStrong
                      ? const Color(0xFF1A2340)
                      : const Color(0xFF3A4560),
        ),
      ),
    );
  }
}

class _ReportMatrix {
  _ReportMatrix({
    required this.months,
    required this.employeeNames,
    required this.lookup,
    required this.grandTotal,
  });

  final List<String> months;
  final List<String> employeeNames;
  final Map<String, Map<String, double>> lookup;
  final double grandTotal;

  factory _ReportMatrix.fromItems(List<SalaryDetailItem> items) {
    final monthKeys = <String>{};
    final employeeNames = <String>[];
    final lookup = <String, Map<String, double>>{};

    for (final item in items) {
      final monthKey =
          '${item.year}-${item.month.toString().padLeft(2, '0')}';
      monthKeys.add(monthKey);
      if (!employeeNames.contains(item.employeeName)) {
        employeeNames.add(item.employeeName);
      }
      lookup.putIfAbsent(
              monthKey, () => <String, double>{})[item.employeeName] =
          item.amount;
    }

    return _ReportMatrix(
      months: monthKeys.toList()..sort(),
      employeeNames: employeeNames,
      lookup: lookup,
      grandTotal: items.fold(0.0, (sum, item) => sum + item.amount),
    );
  }

  double columnTotal(String month) {
    return (lookup[month]?.values ?? const <double>[])
        .fold(0.0, (sum, amount) => sum + amount);
  }
}

class _EmptyBatchData extends StatelessWidget {
  const _EmptyBatchData();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_chart_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('该批次范围内暂无工资数据',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
        ],
      ),
    );
  }
}
