import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'workbench_viewmodel.dart';

class WorkbenchScreen extends ConsumerStatefulWidget {
  const WorkbenchScreen({super.key});

  @override
  ConsumerState<WorkbenchScreen> createState() => _WorkbenchScreenState();
}

class _WorkbenchScreenState extends ConsumerState<WorkbenchScreen> {
  final _controllers = <int, TextEditingController>{};
  final _focusNodes = <int, FocusNode>{};
  final _fmt = NumberFormat('#,##0.00', 'zh_CN');

  // 上次已加载的年月，用于检测切换
  int _lastLoadedYear = 0;
  int _lastLoadedMonth = 0;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int id) =>
      _controllers.putIfAbsent(id, () => TextEditingController());

  FocusNode _focusNodeFor(int id) =>
      _focusNodes.putIfAbsent(id, () => FocusNode());

  /// 切换月份时重置并重新预填控制器
  void _resetAndPrefill(WorkbenchState state) {
    for (final c in _controllers.values) {
      c.clear();
    }
    for (final entry in state.savedAmounts.entries) {
      final c = _controllerFor(entry.key);
      c.text = entry.value.toStringAsFixed(2);
    }
    _lastLoadedYear = state.selectedYear;
    _lastLoadedMonth = state.selectedMonth;
  }

  Future<void> _saveAll(WorkbenchState state) async {
    final amounts = <int, double>{};
    for (final emp in state.employees) {
      final text = _controllers[emp.id]?.text.trim() ?? '';
      final amount = double.tryParse(text) ?? 0.0;
      amounts[emp.id] = amount;
    }
    await ref.read(workbenchViewModelProvider.notifier).saveAll(amounts);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('保存成功'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workbenchViewModelProvider);

    // 检测月份切换或首次加载完成时，重置控制器
    if (!state.isLoading &&
        (state.selectedYear != _lastLoadedYear ||
            state.selectedMonth != _lastLoadedMonth)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resetAndPrefill(state);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('工作台'),
        actions: [
          TextButton(
            onPressed: state.isLoading ? null : () => _saveAll(state),
            child: Text(
              '保存',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _MonthSelector(
                  year: state.selectedYear,
                  month: state.selectedMonth,
                  total: state.totalAmount,
                  fmt: _fmt,
                  onPrev: () =>
                      ref.read(workbenchViewModelProvider.notifier).prevMonth(),
                  onNext: () =>
                      ref.read(workbenchViewModelProvider.notifier).nextMonth(),
                ),
                Expanded(
                  child: state.employees.isEmpty
                      ? _EmptyEmployee()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: state.employees.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final emp = state.employees[i];
                            final saved = state.savedAmounts[emp.id];
                            return _EmployeeInputTile(
                              employee: emp,
                              controller: _controllerFor(emp.id),
                              focusNode: _focusNodeFor(emp.id),
                              isSaved: saved != null,
                              savedLabel: saved != null
                                  ? '¥ ${_fmt.format(saved)}'
                                  : null,
                              onSubmitted: () {
                                final nextIndex = i + 1;
                                if (nextIndex < state.employees.length) {
                                  _focusNodeFor(
                                          state.employees[nextIndex].id)
                                      .requestFocus();
                                } else {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// ── 月份选择器 ─────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.year,
    required this.month,
    required this.total,
    required this.fmt,
    required this.onPrev,
    required this.onNext,
  });

  final int year;
  final int month;
  final double total;
  final NumberFormat fmt;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            const Color(0xFF5C6BC0)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 月份切换行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                '$year年$month月',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 总额
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '本月合计  ¥ ',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              ),
              Text(
                fmt.format(total),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 员工输入卡片 ───────────────────────────────────────

class _EmployeeInputTile extends StatelessWidget {
  const _EmployeeInputTile({
    required this.employee,
    required this.controller,
    required this.focusNode,
    required this.isSaved,
    required this.onSubmitted,
    this.savedLabel,
  });

  final Employee employee;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSaved;
  final String? savedLabel;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSaved
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.12),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: isSaved
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
              )
            : null,
        title: Text(employee.name,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: savedLabel != null
            ? Text('已存: $savedLabel',
                style: const TextStyle(fontSize: 12, color: Colors.green))
            : null,
        trailing: SizedBox(
          width: 140,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.end,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => onSubmitted(),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
                fontSize: 18),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '¥ ',
              prefixStyle:
                  const TextStyle(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyEmployee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('请先在员工库添加员工',
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}
