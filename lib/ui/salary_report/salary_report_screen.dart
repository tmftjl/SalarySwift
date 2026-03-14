import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/repository/batch_repository.dart';
import 'package:salary_swift/util/top_notification.dart';

import 'salary_report_detail_screen.dart';
import 'salary_report_viewmodel.dart';

class SalaryReportScreen extends ConsumerWidget {
  const SalaryReportScreen({super.key});

  String _batchLabel(SalaryBatch batch) {
    final start = '${batch.startYear}年${batch.startMonth}月';
    final end = '${batch.endYear}年${batch.endMonth}月';
    return start == end ? start : '$start - $end';
  }

  String _batchErrorMessage(BatchCreationError error) {
    switch (error) {
      case BatchCreationError.invalidRange:
        return '结束月份不能早于开始月份';
      case BatchCreationError.duplicateRange:
        return '相同时间范围的结算批次已存在';
      case BatchCreationError.tooManyMonths:
        return '结算范围最多 12 个月';
    }
  }

  Future<void> _showCreateBatchDialog(
      BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    int startYear = now.year;
    int startMonth = now.month;
    int endYear = now.year;
    int endMonth = now.month;
    final years = List.generate(11, (i) => now.year - 5 + i);

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('新建结算批次',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('开始月份',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _YearMonthDropdown(
                      label: '年',
                      value: startYear,
                      items: years,
                      onChanged: (v) => setS(() => startYear = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _YearMonthDropdown(
                      label: '月',
                      value: startMonth,
                      items: List.generate(12, (i) => i + 1),
                      onChanged: (v) => setS(() => startMonth = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('结束月份',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _YearMonthDropdown(
                      label: '年',
                      value: endYear,
                      items: years,
                      onChanged: (v) => setS(() => endYear = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _YearMonthDropdown(
                      label: '月',
                      value: endMonth,
                      items: List.generate(12, (i) => i + 1),
                      onChanged: (v) => setS(() => endMonth = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('创建'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final error = await ref
          .read(salaryReportViewModelProvider.notifier)
          .createBatch(startYear, startMonth, endYear, endMonth);
      if (error != null && context.mounted) {
        showTopNotification(context, _batchErrorMessage(error), isError: true);
      }
    }
  }

  Future<void> _deleteBatch(
    BuildContext context,
    WidgetRef ref,
    SalaryBatch batch,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        title: const Text('删除批次？'),
        content: const Text('仅删除批次记录，不影响工资数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await ref
          .read(salaryReportViewModelProvider.notifier)
          .deleteBatch(batch.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salaryReportViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('工资报表')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.batches.isEmpty
              ? _EmptyReport()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.batches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final batch = state.batches[i];
                    return _BatchCard(
                      label: _batchLabel(batch),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SalaryReportDetailScreen(batch: batch),
                          ),
                        );
                      },
                      onDelete: () => _deleteBatch(context, ref, batch),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBatchDialog(context, ref),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        label: const Text('结算', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.receipt_long_outlined),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  const _BatchCard({
    required this.label,
    required this.onTap,
    required this.onDelete,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFFE8EEF8), width: 1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.receipt_long_outlined,
                      color: primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                  tooltip: '删除批次',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('暂无结算批次',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          const SizedBox(height: 6),
          Text('点击右下角 + 新建结算批次',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }
}

class _YearMonthDropdown extends StatelessWidget {
  const _YearMonthDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> items;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              onChanged(v);
            }
          },
        ),
      ),
    );
  }
}
