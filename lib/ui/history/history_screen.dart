import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'history_viewmodel.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyViewModelProvider);
    final fmt = NumberFormat('#,##0.00', 'zh_CN');

    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.months.isEmpty
              ? _EmptyHistory()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.months.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final m = state.months[i];
                    return _MonthCard(
                      title: '${m.year}年${m.month}月',
                      count: m.employeeCount,
                      amount: fmt.format(m.totalAmount),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailScreen(
                              year: m.year, month: m.month),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.title,
    required this.count,
    required this.amount,
    required this.onTap,
  });

  final String title;
  final int count;
  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.calendar_today_outlined,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('$count 人',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('¥ $amount',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2D3436))),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right,
                      size: 20, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('暂无工资记录',
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}
