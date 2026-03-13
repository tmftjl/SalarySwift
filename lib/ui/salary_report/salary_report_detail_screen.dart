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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_batchDetailProvider(batch));

    return Scaffold(
      appBar: AppBar(
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

  String _batchLabel(SalaryBatch batch) {
    final start = '${batch.startYear}年${batch.startMonth}月';
    final end = '${batch.endYear}年${batch.endMonth}月';
    return start == end ? start : '$start ~ $end';
  }
}

class _ReportPreview extends StatelessWidget {
  const _ReportPreview({
    required this.batch,
    required this.items,
  });

  final SalaryBatch batch;
  final List<SalaryDetailItem> items;

  @override
  Widget build(BuildContext context) {
    final data = _ReportMatrix.fromItems(items);
    final fmt = NumberFormat('#,##0.00', 'zh_CN');
    final tableWidth = 120.0 + data.months.length * 110.0 + 120.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '工资汇总表  ${_batchLabel(batch)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '共 ${data.employeeNames.length} 人  ${data.months.length} 个月',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _ReportRow(
                            backgroundColor: const Color(0xFFECEFF6),
                            cells: [
                              const _ReportCell('姓名',
                                  width: 120, isHeader: true),
                              ...data.months.map(
                                (month) => _ReportCell(
                                  _fmtMonthKey(month),
                                  width: 110,
                                  isHeader: true,
                                ),
                              ),
                              const _ReportCell('合计',
                                  width: 120,
                                  align: TextAlign.right,
                                  isHeader: true),
                            ],
                          ),
                          ...data.employeeNames.map((name) {
                            var total = 0.0;
                            final cells = <_ReportCell>[
                              _ReportCell(name, width: 120),
                            ];
                            for (final month in data.months) {
                              final amount = data.lookup[month]?[name] ?? 0.0;
                              total += amount;
                              cells.add(
                                _ReportCell(
                                  amount > 0 ? fmt.format(amount) : '-',
                                  width: 110,
                                  align: TextAlign.right,
                                ),
                              );
                            }
                            cells.add(
                              _ReportCell(
                                fmt.format(total),
                                width: 120,
                                align: TextAlign.right,
                                isStrong: true,
                              ),
                            );
                            return _ReportRow(cells: cells);
                          }),
                          _ReportRow(
                            backgroundColor: const Color(0xFFF5F7FA),
                            cells: [
                              const _ReportCell('合计',
                                  width: 120, isStrong: true),
                              ...data.months.map(
                                (month) => _ReportCell(
                                  fmt.format(data.columnTotal(month)),
                                  width: 110,
                                  align: TextAlign.right,
                                  isStrong: true,
                                ),
                              ),
                              _ReportCell(
                                fmt.format(data.grandTotal),
                                width: 120,
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
          ],
        ),
      ),
    );
  }

  String _batchLabel(SalaryBatch batch) {
    final start = '${batch.startYear}年${batch.startMonth}月';
    final end = '${batch.endYear}年${batch.endMonth}月';
    return start == end ? start : '$start ~ $end';
  }

  String _fmtMonthKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) {
      return key;
    }
    return '${parts[0]}年 ${int.tryParse(parts[1]) ?? parts[1]}月';
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
  });

  final String text;
  final double width;
  final TextAlign align;
  final bool isHeader;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade300;
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: borderColor),
          top: BorderSide(color: borderColor),
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      alignment:
          align == TextAlign.right ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 13 : 12,
          fontWeight:
              isHeader || isStrong ? FontWeight.w700 : FontWeight.w500,
          color: const Color(0xFF2D3436),
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
      final monthKey = '${item.year}-${item.month.toString().padLeft(2, '0')}';
      monthKeys.add(monthKey);
      if (!employeeNames.contains(item.employeeName)) {
        employeeNames.add(item.employeeName);
      }
      lookup.putIfAbsent(monthKey, () => <String, double>{})[item.employeeName] =
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
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('该批次范围内暂无工资数据',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}
