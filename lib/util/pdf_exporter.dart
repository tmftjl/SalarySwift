import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:salary_swift/data/db/app_database.dart';
import 'package:salary_swift/data/db/dao/salary_record_dao.dart';
import 'package:share_plus/share_plus.dart';

class PdfExporter {
  PdfExporter._();

  /// 导出跨月工资汇总表格（历史工资页用）
  /// items 已包含 year/month 字段，按批次时间范围查出
  static Future<void> exportSalaryReport({
    required SalaryBatch batch,
    required List<SalaryDetailItem> items,
  }) async {
    final pdf = await _buildReportPdf(batch, items);
    final bytes = await pdf.save();

    final label =
        '工资${batch.startYear}${_pad(batch.startMonth)}-${batch.endYear}${_pad(batch.endMonth)}';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$label.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: '工资汇总表',
    );
  }

  // ── 跨月工资汇总表 ─────────────────────────────────────

  static Future<pw.Document> _buildReportPdf(
      SalaryBatch batch, List<SalaryDetailItem> items) async {
    final regularFont = await _loadFont('assets/fonts/SimHei.ttf');
    final boldFont = regularFont;
    final fontFallback = <pw.Font>[regularFont, boldFont];
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      fontFallback: fontFallback,
    );
    final pdf = pw.Document(theme: theme);
    final fmt = NumberFormat('#,##0.00', 'zh_CN');

    // 提取所有月份列（排序去重）
    final monthKeys = <String>{};
    for (final i in items) {
      monthKeys.add('${i.year}-${_pad(i.month)}');
    }
    final months = monthKeys.toList()..sort();

    // 提取所有员工（按首次出现顺序去重）
    final employeeNames = <String>[];
    for (final i in items) {
      if (!employeeNames.contains(i.employeeName)) {
        employeeNames.add(i.employeeName);
      }
    }

    // 建立查找表: "YYYY-MM" -> employeeName -> amount
    final lookup = <String, Map<String, double>>{};
    for (final i in items) {
      final key = '${i.year}-${_pad(i.month)}';
      lookup.putIfAbsent(key, () => <String, double>{})[i.employeeName] = i.amount;
    }

    final colCount = 1 + months.length + 1; // 姓名 + 各月 + 合计

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(52),
      colCount - 1: const pw.FixedColumnWidth(68),
    };
    for (int i = 1; i < colCount - 1; i++) {
      columnWidths[i] = const pw.FlexColumnWidth(1);
    }

    // 表头行
    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF1565C0)),
      children: [
        _cell('姓名', boldFont,
            fontFallback: fontFallback,
            isHeader: true,
            textColor: PdfColors.white),
        ...months.map((m) => _cell(_fmtMonthKey(m), boldFont,
            fontFallback: fontFallback,
            isHeader: true,
            fontSize: 9,
            align: pw.TextAlign.center,
            textColor: PdfColors.white)),
        _cell('合计', boldFont,
            fontFallback: fontFallback,
            isHeader: true,
            align: pw.TextAlign.right,
            textColor: PdfColors.white),
      ],
    );

    // 数据行
    final dataRows = employeeNames.asMap().entries.map((entry) {
      final idx = entry.key;
      final name = entry.value;
      double total = 0;
      final cells = <pw.Widget>[
        _cell(name, regularFont, fontFallback: fontFallback)
      ];
      for (final m in months) {
        final amt = lookup[m]?[name] ?? 0;
        total += amt;
        cells.add(_cell(
          amt > 0 ? fmt.format(amt) : '–',
          regularFont,
          fontFallback: fontFallback,
          align: pw.TextAlign.right,
          fontSize: 9,
          textColor: amt > 0 ? PdfColors.black : PdfColors.grey400,
        ));
      }
      cells.add(_cell(fmt.format(total), boldFont,
          fontFallback: fontFallback, align: pw.TextAlign.right, fontSize: 9));
      return pw.TableRow(
        decoration: pw.BoxDecoration(
            color: idx.isOdd
                ? PdfColor.fromInt(0xFFF7FAFF)
                : PdfColors.white),
        children: cells,
      );
    }).toList();

    // 合计行
    final totalRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F1FF)),
      children: [
        _cell('合计', boldFont, fontFallback: fontFallback),
        ...months.map((m) {
          final colTotal =
              (lookup[m]?.values ?? []).fold(0.0, (s, a) => s + a);
          return _cell(fmt.format(colTotal), boldFont,
              fontFallback: fontFallback,
              align: pw.TextAlign.right, fontSize: 9);
        }),
        () {
          final grand = items.fold(0.0, (s, i) => s + i.amount);
          return _cell(fmt.format(grand), boldFont,
              fontFallback: fontFallback,
              align: pw.TextAlign.right, fontSize: 9);
        }(),
      ],
    );

    final batchLabel = _batchLabel(batch);

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          theme: theme,
        ),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(batchLabel,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 14,
                      fontFallback: fontFallback,
                    )),
                pw.Spacer(),
                pw.Text('生成时间：${_nowString()}',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 9,
                      color: PdfColors.grey600,
                      fontFallback: fontFallback,
                    )),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromInt(0xFFCDD8F0), width: 0.6),
              columnWidths: columnWidths,
              children: [headerRow, ...dataRows, totalRow],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  // ── 工具方法 ───────────────────────────────────────────

  static pw.Widget _cell(
    String text,
    pw.Font font, {
    List<pw.Font> fontFallback = const [],
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    double fontSize = 10,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 9.5 : fontSize,
          fontFallback: fontFallback,
          color: textColor,
        ),
        textAlign: align,
      ),
    );
  }

  static String _batchLabel(SalaryBatch batch) {
    final start = '${batch.startYear}年${batch.startMonth}月';
    final end = '${batch.endYear}年${batch.endMonth}月';
    return start == end ? start : '$start - $end';
  }

  static String _fmtMonthKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return key;
    final y = (int.tryParse(parts[0]) ?? 0) % 100;
    final m = int.tryParse(parts[1]) ?? 0;
    return '${_pad(y)}年${_pad(m)}月';
  }

  static String _nowString() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
        '${_pad(now.hour)}:${_pad(now.minute)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static Future<pw.Font> _loadFont(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return pw.Font.ttf(data);
  }
}
