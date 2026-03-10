import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';
import 'package:salary_swift/data/repository/salary_repository.dart';
import 'package:salary_swift/util/pdf_exporter.dart';

final _batchDetailProvider =
    FutureProvider.family<List<BatchDetailItem>, String>((ref, batchKey) {
  return ref.watch(salaryRepositoryProvider).getBatchDetail(batchKey);
});

class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.batchKey});

  final String batchKey;

  String get _title {
    final parts = batchKey.split('-');
    if (parts.length != 2) return batchKey;
    return '${parts[0]}年${int.tryParse(parts[1]) ?? parts[1]}月';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(_batchDetailProvider(batchKey));
    final fmt = NumberFormat('#,##0.00', 'zh_CN');

    return Scaffold(
      appBar: AppBar(
        title: Text('$_title 详情'),
      ),
      body: asyncDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错了：$e')),
        data: (items) {
          final total = items.fold(0.0, (s, i) => s + i.amount);
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          _SmallAvatar(name: item.employeeName),
                          const SizedBox(width: 12),
                          Text(item.employeeName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                          const Spacer(),
                          Text('¥ ${fmt.format(item.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _TotalSummaryBar(total: fmt.format(total), onExport: () => _exportPdf(context, items)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, List<BatchDetailItem> items) async {
    try {
      await PdfExporter.exportAndShare(batchKey: batchKey, items: items);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败：$e')));
      }
    }
  }
}

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(name.isNotEmpty ? name.substring(0, 1) : '?', 
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}

class _TotalSummaryBar extends StatelessWidget {
  const _TotalSummaryBar({required this.total, required this.onExport});
  final String total;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('合计金额', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('¥ $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF2D3436))),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onExport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.share_outlined, size: 20),
            label: const Text('导出分享', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
