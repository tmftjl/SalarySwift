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

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    for (final f in _focusNodes.values) f.dispose();
    super.dispose();
  }

  TextEditingController _controllerFor(int id) =>
      _controllers.putIfAbsent(id, () => TextEditingController());

  FocusNode _focusNodeFor(int id) =>
      _focusNodes.putIfAbsent(id, () => FocusNode());

  Future<void> _onSubmitAmount(
    int employeeId,
    List<int> pendingIds,
    int currentIndex,
  ) async {
    final text = _controllerFor(employeeId).text.trim();
    final amount = double.tryParse(text);
    if (amount != null && amount > 0) {
      await ref
          .read(workbenchViewModelProvider.notifier)
          .saveAmount(employeeId, amount);
      _controllerFor(employeeId).clear();
    }

    final nextIndex = currentIndex + 1;
    if (nextIndex < pendingIds.length) {
      _focusNodeFor(pendingIds[nextIndex]).requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _showEditAmountDialog(Employee employee, double initialAmount) async {
    final controller = TextEditingController(text: initialAmount.toStringAsFixed(2));

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('修改 ${employee.name} 的金额'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            prefixText: '¥ ',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim());
              if (amount == null || amount <= 0) {
                return;
              }

              await ref
                  .read(workbenchViewModelProvider.notifier)
                  .saveAmount(employee.id, amount);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSettle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认结算？'),
        content: const Text('结算后当月数据将存入历史记录，工作台清空。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认结算')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(workbenchViewModelProvider.notifier).settle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('结算成功！'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workbenchViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('工作台'),
        actions: [
          IconButton(
            onPressed: () => ref.read(workbenchViewModelProvider.notifier).importLastMonth(),
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: '导入上月',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _TotalHeroCard(total: state.totalAmount, fmt: _fmt),
                ),
                if (state.pendingEmployees.isNotEmpty) ...[
                  _SectionTitle(title: '待录入', count: state.pendingEmployees.length, color: Colors.orange),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: state.pendingEmployees.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final emp = state.pendingEmployees[i];
                        final pendingIds = state.pendingEmployees.map((e) => e.id).toList();
                        return _PendingInputTile(
                          name: emp.name,
                          controller: _controllerFor(emp.id),
                          focusNode: _focusNodeFor(emp.id),
                          onSubmitted: () => _onSubmitAmount(emp.id, pendingIds, i),
                        );
                      },
                    ),
                  ),
                ],
                if (state.enteredEmployees.isNotEmpty) ...[
                  _SectionTitle(title: '已录入', count: state.enteredEmployees.length, color: Colors.green),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: state.enteredEmployees.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final emp = state.enteredEmployees[i];
                        final amount = state.enteredAmounts[emp.id] ?? 0;
                        return _EnteredTile(
                          name: emp.name,
                          amount: _fmt.format(amount),
                          onEdit: () => _showEditAmountDialog(emp, amount),
                          onUndo: () => ref.read(workbenchViewModelProvider.notifier).undoAmount(emp.id),
                        );
                      },
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
      floatingActionButton: state.enteredEmployees.isNotEmpty && state.pendingEmployees.isEmpty
          ? FloatingActionButton.extended(
              onPressed: _confirmSettle,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.done_all),
              label: const Text('完成并归档', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _TotalHeroCard extends StatelessWidget {
  const _TotalHeroCard({required this.total, required this.fmt});
  final double total;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, const Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('本月发放总额', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('¥ ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(fmt.format(total), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count, required this.color});
  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          children: [
            Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            const SizedBox(width: 6),
            Text('$count', style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PendingInputTile extends StatelessWidget {
  const _PendingInputTile({required this.name, required this.controller, required this.focusNode, required this.onSubmitted});
  final String name;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        trailing: SizedBox(
          width: 130,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => onSubmitted(),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '¥ ',
              prefixStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ),
    );
  }
}

class _EnteredTile extends StatelessWidget {
  const _EnteredTile({
    required this.name,
    required this.amount,
    required this.onEdit,
    required this.onUndo,
  });
  final String name;
  final String amount;
  final VoidCallback onEdit;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withValues(alpha: 0.05))),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¥ $amount', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey)),
            IconButton(onPressed: onUndo, icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
