import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'employees_viewmodel.dart';
import '../../data/db/app_database.dart';

class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(employeesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('员工管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () => _showAddDialog(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错了：$e')),
        data: (employees) => employees.isEmpty
            ? _EmptyState(onAdd: () => _showAddDialog(context, ref))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: employees.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final emp = employees[i];
                  return _EmployeeCard(
                    employee: emp,
                    onEdit: () => _showEditDialog(context, ref, emp),
                    onDelete: () async {
                      final confirm = await _confirmDelete(context, emp.name);
                      if (confirm == true) {
                        await ref
                            .read(employeesViewModelProvider.notifier)
                            .deleteEmployee(emp.id);
                        return true;
                      }

                      return false;
                    },
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModernBottomSheet(
        title: '新增员工',
        child: Column(
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '输入员工姓名',
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    ref.read(employeesViewModelProvider.notifier).addEmployee(name);
                    Navigator.pop(ctx);
                  }
                },
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('保存员工', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref,  Employee employee) async {
    final controller = TextEditingController(text: employee.name);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改姓名'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != employee.name) {
                ref.read(employeesViewModelProvider.notifier).updateName(employee, name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除？'),
        content: Text('删除「$name」后，未来将不再显示在工作台中，但历史工资记录会保留。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee, required this.onEdit, required this.onDelete});
  final Employee employee;
  final VoidCallback onEdit;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(employee.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete(),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          onTap: onEdit,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _Avatar(name: employee.name),
          title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          subtitle: Text(
            '入职于: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(employee.createdAt))}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          trailing: Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;

  Color _getColor() {
    final colors = [const Color(0xFF5C6BC0), const Color(0xFF66BB6A), const Color(0xFFFFA726), const Color(0xFFEF5350), const Color(0xFF26C6DA)];
    return colors[name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: _getColor().withValues(alpha: 0.1), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name.substring(0, 1) : '?',
        style: TextStyle(color: _getColor(), fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}

class _ModernBottomSheet extends StatelessWidget {
  const _ModernBottomSheet({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('还没有员工', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          const SizedBox(height: 24),
          TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('立即添加')),
        ],
      ),
    );
  }
}
