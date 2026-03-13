import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/ui/history/history_viewmodel.dart';
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

  double _parseAmount(String text) => double.tryParse(text.trim()) ?? 0.0;

  void _syncCachesForEmployees(List<Employee> employees) {
    final validIds = employees.map((e) => e.id).toSet();

    final removedControllerIds = _controllers.keys
        .where((id) => !validIds.contains(id))
        .toList(growable: false);
    for (final id in removedControllerIds) {
      _controllers.remove(id)?.dispose();
    }

    final removedFocusIds = _focusNodes.keys
        .where((id) => !validIds.contains(id))
        .toList(growable: false);
    for (final id in removedFocusIds) {
      _focusNodes.remove(id)?.dispose();
    }
  }

  void _syncControllersFromState(WorkbenchState state) {
    _syncCachesForEmployees(state.employees);

    for (final employee in state.employees) {
      final draftAmount =
          state.draftAmounts[employee.id] ?? state.savedAmounts[employee.id] ?? 0.0;
      final controller = _controllerFor(employee.id);
      final desiredText = draftAmount > 0 ? draftAmount.toStringAsFixed(2) : '';
      final focusNode = _focusNodes[employee.id];
      if (controller.text != desiredText && !(focusNode?.hasFocus ?? false)) {
        controller.text = desiredText;
      }
    }
  }

  bool _hasPendingChanges(WorkbenchState state) {
    for (final employee in state.employees) {
      final saved = state.savedAmounts[employee.id] ?? 0.0;
      final draft = state.draftAmounts[employee.id] ?? saved;
      if ((saved - draft).abs() > 0.0001) {
        return true;
      }
    }
    return false;
  }

  double _draftTotal(WorkbenchState state) {
    var total = 0.0;
    for (final employee in state.employees) {
      total += state.draftAmounts[employee.id] ??
          (state.savedAmounts[employee.id] ?? 0.0);
    }
    return total;
  }

  Map<int, double> _collectChangedAmounts(WorkbenchState state) {
    final changed = <int, double>{};
    for (final employee in state.employees) {
      final saved = state.savedAmounts[employee.id] ?? 0.0;
      final draft = state.draftAmounts[employee.id] ?? saved;
      if ((saved - draft).abs() <= 0.0001) {
        continue;
      }
      changed[employee.id] = draft;
    }
    return changed;
  }

  Future<bool> _confirmDiscardChanges() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('放弃未保存修改？'),
        content: const Text('你刚修改的工资还没保存，切换月份后这些修改会丢失。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('继续编辑'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('放弃并切换'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  Future<void> _handleMonthChange(
    WorkbenchState state,
    Future<void> Function() changeAction,
  ) async {
    if (state.isLoading || state.isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (_hasPendingChanges(state)) {
      final shouldDiscard = await _confirmDiscardChanges();
      if (!shouldDiscard || !mounted) {
        return;
      }
    }

    await changeAction();
  }

  Future<void> _saveAll(WorkbenchState state) async {
    final amounts = _collectChangedAmounts(state);
    if (amounts.isEmpty) {
      return;
    }

    await ref.read(workbenchViewModelProvider.notifier).saveAll(amounts);
    ref.invalidate(historyViewModelProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('保存成功'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workbenchViewModelProvider);
    if (!state.isLoading) {
      _syncControllersFromState(state);
    }

    final hasPendingChanges = _hasPendingChanges(state);
    final totalAmount = _draftTotal(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('工作台'),
        actions: [
          TextButton(
            onPressed: state.isLoading || state.isSaving || !hasPendingChanges
                ? null
                : () => _saveAll(state),
            child: Text(
              state.isSaving ? '保存中' : '保存',
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
                  total: totalAmount,
                  fmt: _fmt,
                  hasPendingChanges: hasPendingChanges,
                  canChangeMonth: !state.isLoading && !state.isSaving,
                  onPrev: () => _handleMonthChange(
                    state,
                    () => ref.read(workbenchViewModelProvider.notifier).prevMonth(),
                  ),
                  onNext: () => _handleMonthChange(
                    state,
                    () => ref.read(workbenchViewModelProvider.notifier).nextMonth(),
                  ),
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
                            final saved = state.savedAmounts[emp.id] ?? 0.0;
                            final draft = state.draftAmounts[emp.id] ?? saved;
                            final isDirty = (saved - draft).abs() > 0.0001;
                            return _EmployeeInputTile(
                              employee: emp,
                              controller: _controllerFor(emp.id),
                              focusNode: _focusNodeFor(emp.id),
                              isSaved: saved > 0,
                              isDirty: isDirty,
                              savedLabel:
                                  saved > 0 ? '¥ ${_fmt.format(saved)}' : null,
                              onChanged: (value) {
                                ref
                                    .read(workbenchViewModelProvider.notifier)
                                    .updateDraftAmount(emp.id, _parseAmount(value));
                              },
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
    required this.hasPendingChanges,
    required this.canChangeMonth,
    required this.onPrev,
    required this.onNext,
  });

  final int year;
  final int month;
  final double total;
  final NumberFormat fmt;
  final bool hasPendingChanges;
  final bool canChangeMonth;
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
                onPressed: canChangeMonth ? onPrev : null,
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
                onPressed: canChangeMonth ? onNext : null,
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
                hasPendingChanges ? '待保存合计  ¥ ' : '本月合计  ¥ ',
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
          if (hasPendingChanges) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '已修改，点击右上角保存后写入数据库',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 12,
                ),
              ),
            ),
          ],
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
    required this.isDirty,
    required this.onChanged,
    required this.onSubmitted,
    this.savedLabel,
  });

  final Employee employee;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSaved;
  final bool isDirty;
  final String? savedLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDirty
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)
              : isSaved
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
            ? Text(
                isDirty ? '原值: $savedLabel' : '已存: $savedLabel',
                style: TextStyle(
                  fontSize: 12,
                  color: isDirty
                      ? Theme.of(context).colorScheme.primary
                      : Colors.green,
                ),
              )
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
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
            ],
            textInputAction: TextInputAction.next,
            onChanged: onChanged,
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
