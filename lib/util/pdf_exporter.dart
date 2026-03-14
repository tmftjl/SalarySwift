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
    final fmt = NumberFormat('0.00');

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

    // A4竖向可用宽度 567pt：名字46 + 12×38 + 合计48 = 550pt，留余量
    const nameColW = 46.0;
    const monthColW = 38.0;
    const totalColW = 48.0;
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(nameColW),
      colCount - 1: const pw.FixedColumnWidth(totalColW),
    };
    for (int i = 1; i < colCount - 1; i++) {
      columnWidths[i] = const pw.FixedColumnWidth(monthColW);
    }

    // 表头行
    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF1565C0)),
      children: [
        _cell('姓名', boldFont,
            fontFallback: fontFallback,
            isHeader: true,
            align: pw.TextAlign.center,
            textColor: PdfColors.white),
        ...months.map((m) => _cell(_fmtMonthKey(m), boldFont,
            fontFallback: fontFallback,
            isHeader: true,
            fontSize: 7,
            align: pw.TextAlign.center,
            textColor: PdfColors.white)),
        _cell('合计', boldFont,
            fontFallback: fontFallback,
            isHeader: true,
            align: pw.TextAlign.center,
            textColor: PdfColors.white),
      ],
    );

    // 数据行
    final dataRows = employeeNames.asMap().entries.map((entry) {
      final idx = entry.key;
      final name = entry.value;
      double total = 0;
      final cells = <pw.Widget>[
        _cell(name, regularFont, fontFallback: fontFallback, align: pw.TextAlign.center)
      ];
      for (final m in months) {
        final amt = lookup[m]?[name] ?? 0;
        total += amt;
        cells.add(_cell(
          amt > 0 ? fmt.format(amt) : '–',
          regularFont,
          fontFallback: fontFallback,
          align: pw.TextAlign.right,
          fontSize: 6,
          textColor: amt > 0 ? PdfColors.black : PdfColors.grey400,
        ));
      }
      cells.add(_cell(fmt.format(total), boldFont,
          fontFallback: fontFallback, align: pw.TextAlign.right, fontSize: 6));
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
        _cell('合计', boldFont, fontFallback: fontFallback, align: pw.TextAlign.center),
        ...months.map((m) {
          final colTotal =
              (lookup[m]?.values ?? []).fold(0.0, (s, a) => s + a);
          return _cell(fmt.format(colTotal), boldFont,
              fontFallback: fontFallback,
              align: pw.TextAlign.right, fontSize: 6);
        }),
        () {
          final grand = items.fold(0.0, (s, i) => s + i.amount);
          return _cell(fmt.format(grand), boldFont,
              fontFallback: fontFallback,
              align: pw.TextAlign.right, fontSize: 6);
        }(),
      ],
    );

    final batchLabel = _batchLabel(batch);
    final tableBorder =
        pw.TableBorder.all(color: PdfColor.fromInt(0xFFCDD8F0), width: 0.6);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          theme: theme,
        ),
        // 每页顶部重复表头
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(batchLabel,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 11,
                      fontFallback: fontFallback,
                    )),
                pw.Spacer(),
                pw.Text(
                    '生成时间：${_nowString()}',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 7,
                      color: PdfColors.grey600,
                      fontFallback: fontFallback,
                    )),
              ],
            ),
            pw.SizedBox(height: 8),
            // 列标题行在每页重复
            pw.Table(
              border: tableBorder,
              columnWidths: columnWidths,
              children: [headerRow],
            ),
          ],
        ),
        build: (ctx) => [
          pw.Table(
            border: tableBorder,
            columnWidths: columnWidths,
            children: [...dataRows, totalRow],
          ),
        ],
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
    double fontSize = 7,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 7.5 : fontSize,
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
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static Future<pw.Font> _loadFont(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return pw.Font.ttf(data);
  }
}
