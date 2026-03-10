import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';
import 'package:share_plus/share_plus.dart';

class PdfExporter {
  PdfExporter._();

  /// 生成 PDF 并通过系统分享面板分享
  static Future<void> exportAndShare({
    required String batchKey,
    required List<BatchDetailItem> items,
  }) async {
    final pdf = await _buildPdf(batchKey, items);
    final bytes = await pdf.save();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/salary_$batchKey.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: '$batchKey 工资单',
    );
  }

  static Future<pw.Document> _buildPdf(
      String batchKey, List<BatchDetailItem> items) async {
    final pdf = pw.Document();
    final fmt = NumberFormat('#,##0.00', 'zh_CN');

    // 加载支持中文的字体
    final fontData = await rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    final boldFontData =
        await rootBundle.load('assets/fonts/NotoSansSC-Bold.ttf');
    final boldFont = pw.Font.ttf(boldFontData);

    final title = _formatBatchKey(batchKey);
    final totalAmount = items.fold(0.0, (s, i) => s + i.amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 标题
              pw.Text(
                '$title 工资明细',
                style: pw.TextStyle(font: boldFont, fontSize: 18),
              ),
              pw.SizedBox(height: 16),

              // 表格
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  // 表头
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.blueGrey100),
                    children: [
                      _cell('员工', boldFont, isHeader: true),
                      _cell('金额', boldFont, isHeader: true),
                    ],
                  ),
                  // 数据行
                  ...items.map(
                    (item) => pw.TableRow(children: [
                      _cell(item.employeeName, font),
                      _cell('¥ ${fmt.format(item.amount)}', font,
                          align: pw.TextAlign.right),
                    ]),
                  ),
                  // 合计行
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.blueGrey50),
                    children: [
                      _cell('合计', boldFont),
                      _cell('¥ ${fmt.format(totalAmount)}', boldFont,
                          align: pw.TextAlign.right),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Text(
                '共 ${items.length} 人    生成时间：${_nowString()}',
                style: pw.TextStyle(font: font, fontSize: 10,
                    color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _cell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: isHeader ? 12 : 11),
        textAlign: align,
      ),
    );
  }

  static String _formatBatchKey(String batchKey) {
    final parts = batchKey.split('-');
    if (parts.length != 2) return batchKey;
    return '${parts[0]}年${int.tryParse(parts[1]) ?? parts[1]}月';
  }

  static String _nowString() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
        '${_pad(now.hour)}:${_pad(now.minute)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
