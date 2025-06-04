// Backup and Restore Service for Excel
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/dao/income_dao.dart';
import '../database/dao/projections_dao.dart';
import '../database/dao/category_dao.dart';
import '../database/dao/payment_status_dao.dart';
import '../database/dao/upcoming_payments_dao.dart';

class BackupRestoreService {
  final IncomeDao _incomeDao = IncomeDao();
  final ProjectionsDao _projectionsDao = ProjectionsDao();
  final CategoryDao _categoryDao = CategoryDao();
  final PaymentStatusDao _paymentStatusDao = PaymentStatusDao();
  final UpcomingPaymentsDao _upcomingPaymentsDao = UpcomingPaymentsDao();

  Future<void> backupToExcel() async {
    final excel = Excel.createExcel();
    // Category Sheet
    final categories = await _categoryDao.getAllCategories();
    final categorySheet = excel['Category'];
    if (categories.isNotEmpty) {
      categorySheet.appendRow(categories.first.keys.toList());
      for (final row in categories) {
        categorySheet.appendRow(row.values.toList());
      }
    }
    // Payment Status Sheet
    final paymentStatuses = await _paymentStatusDao.getAllPaymentStatuses();
    final paymentStatusSheet = excel['Payments Status'];
    if (paymentStatuses.isNotEmpty) {
      paymentStatusSheet.appendRow(paymentStatuses.first.keys.toList());
      for (final row in paymentStatuses) {
        paymentStatusSheet.appendRow(row.values.toList());
      }
    }
    // Projections Sheet
    final projections = await _projectionsDao.getAllProjections();
    final projectionsSheet = excel['Projections'];
    if (projections.isNotEmpty) {
      projectionsSheet.appendRow(projections.first.keys.toList());
      for (final row in projections) {
        projectionsSheet.appendRow(row.values.toList());
      }
    }
    // Income Sheet
    final incomes = await _incomeDao.getAllIncome();
    final incomeSheet = excel['Income'];
    if (incomes.isNotEmpty) {
      incomeSheet.appendRow(incomes.first.keys.toList());
      for (final row in incomes) {
        incomeSheet.appendRow(row.values.toList());
      }
    }
    // Upcoming Payments Sheet
    final upcomingPayments = await _upcomingPaymentsDao.getAllUpcomingPayments();
    final upcomingSheet = excel['Upcoming Payments'];
    if (upcomingPayments.isNotEmpty) {
      upcomingSheet.appendRow(upcomingPayments.first.keys.toList());
      for (final row in upcomingPayments) {
        upcomingSheet.appendRow(row.values.toList());
      }
    }
    // Save file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/finance_backup_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);
  }

  /// Returns the backup file path after saving
  Future<String> backupToExcelWithPath() async {
    final excel = Excel.createExcel();
    // Category Sheet
    final categories = await _categoryDao.getAllCategories();
    final categorySheet = excel['Category'];
    if (categories.isNotEmpty) {
      categorySheet.appendRow(categories.first.keys.toList());
      for (final row in categories) {
        categorySheet.appendRow(row.values.toList());
      }
    }
    // Payment Status Sheet
    final paymentStatuses = await _paymentStatusDao.getAllPaymentStatuses();
    final paymentStatusSheet = excel['Payments Status'];
    if (paymentStatuses.isNotEmpty) {
      paymentStatusSheet.appendRow(paymentStatuses.first.keys.toList());
      for (final row in paymentStatuses) {
        paymentStatusSheet.appendRow(row.values.toList());
      }
    }
    // Projections Sheet
    final projections = await _projectionsDao.getAllProjections();
    final projectionsSheet = excel['Projections'];
    if (projections.isNotEmpty) {
      projectionsSheet.appendRow(projections.first.keys.toList());
      for (final row in projections) {
        projectionsSheet.appendRow(row.values.toList());
      }
    }
    // Income Sheet
    final incomes = await _incomeDao.getAllIncome();
    final incomeSheet = excel['Income'];
    if (incomes.isNotEmpty) {
      incomeSheet.appendRow(incomes.first.keys.toList());
      for (final row in incomes) {
        incomeSheet.appendRow(row.values.toList());
      }
    }
    // Upcoming Payments Sheet
    final upcomingPayments = await _upcomingPaymentsDao.getAllUpcomingPayments();
    final upcomingSheet = excel['Upcoming Payments'];
    if (upcomingPayments.isNotEmpty) {
      upcomingSheet.appendRow(upcomingPayments.first.keys.toList());
      for (final row in upcomingPayments) {
        upcomingSheet.appendRow(row.values.toList());
      }
    }
    // Save file
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/finance_backup_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);
    return filePath;
  }

  /// Save backup to a custom file path
  Future<void> backupToExcelCustomPath(String? filePath, {void Function(String)? onDebugInfo}) async {
    final excel = Excel.createExcel();
    // Category Sheet
    final categories = await _categoryDao.getAllCategories();
    final categorySheet = excel['Category'];
    if (categories.isNotEmpty) {
      categorySheet.appendRow(categories.first.keys.toList());
      for (final row in categories) {
        categorySheet.appendRow(row.values.toList());
      }
    }
    // Payment Status Sheet
    final paymentStatuses = await _paymentStatusDao.getAllPaymentStatuses();
    final paymentStatusSheet = excel['Payments Status'];
    if (paymentStatuses.isNotEmpty) {
      paymentStatusSheet.appendRow(paymentStatuses.first.keys.toList());
      for (final row in paymentStatuses) {
        paymentStatusSheet.appendRow(row.values.toList());
      }
    }
    // Projections Sheet
    final projections = await _projectionsDao.getAllProjections();
    final projectionsSheet = excel['Projections'];
    if (projections.isNotEmpty) {
      projectionsSheet.appendRow(projections.first.keys.toList());
      for (final row in projections) {
        projectionsSheet.appendRow(row.values.toList());
      }
    }
    // Income Sheet
    final incomes = await _incomeDao.getAllIncome();
    final incomeSheet = excel['Income'];
    if (incomes.isNotEmpty) {
      incomeSheet.appendRow(incomes.first.keys.toList());
      for (final row in incomes) {
        incomeSheet.appendRow(row.values.toList());
      }
    }
    // Upcoming Payments Sheet
    final upcomingPayments = await _upcomingPaymentsDao.getAllUpcomingPayments();
    final upcomingSheet = excel['Upcoming Payments'];
    if (upcomingPayments.isNotEmpty) {
      upcomingSheet.appendRow(upcomingPayments.first.keys.toList());
      for (final row in upcomingPayments) {
        upcomingSheet.appendRow(row.values.toList());
      }
    }
    // Debug: Collect sheet and row info
    final buffer = StringBuffer('Excel sheets:\n');
    for (var sheet in excel.tables.keys) {
      buffer.writeln('Sheet: $sheet, Rows: \\${excel.tables[sheet]?.rows.length}');
    }
    final debugInfo = buffer.toString();
    if (onDebugInfo != null) onDebugInfo(debugInfo);
    // Defensive: Ensure at least one sheet has data
    final hasData = excel.tables.values.any((sheet) => sheet.rows.isNotEmpty);
    if (!hasData) {
      if (onDebugInfo != null) onDebugInfo('No data found in any sheet. Backup aborted.');
      throw Exception('No data found in any sheet. Backup aborted.');
    }
    // Save file to custom path
    String? savePath = filePath;
    if (savePath == null || savePath.isEmpty) {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Select location to save backup',
        fileName: 'finance_backup_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (savePath == null) {
        if (onDebugInfo != null) onDebugInfo('No file path selected for backup');
        throw Exception('No file path selected for backup');
      }
    }
    final file = File(savePath);
    final bytes = excel.encode();
    if (onDebugInfo != null) onDebugInfo('Excel encode bytes: \\${bytes?.length ?? 'null'}');
    if (bytes == null) {
      final err = 'Failed to encode Excel file. Sheet row counts: ' +
        excel.tables.keys.map((k) => '$k=\\${excel.tables[k]?.rows.length}').join(', ') +
        '. This may indicate an API mismatch with the excel package or empty sheets.';
      if (onDebugInfo != null) onDebugInfo(err);
      throw Exception(err);
    }
    await file.writeAsBytes(bytes, flush: true);
    if (onDebugInfo != null) onDebugInfo('Backup written to: $savePath');
  }

  dynamic _parseField(dynamic value) {
    if (value == null) return null;
    if (value is int || value is double) return value;
    if (value is String && double.tryParse(value) != null) return double.parse(value);
    if (value.runtimeType.toString() == 'SharedString') return value.toString();
    return value.toString();
  }

  Future<void> restoreFromExcel() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.single.path!);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    // Restore Category
    final categorySheet = excel['Category'];
    final rows = categorySheet.rows;
    if (rows.length > 1) {
      final keys = rows.first.map((e) => _parseField(e?.value)).toList();
      for (var i = 1; i < rows.length; i++) {
        final values = rows[i].map((e) => _parseField(e?.value)).toList();
        final map = Map.fromIterables(keys, values);
        await _categoryDao.insertOrUpdateFromMap(map);
      }
    }
    // Restore Payment Status
    final paymentStatusSheet = excel['Payments Status'];
    final psRows = paymentStatusSheet.rows;
    if (psRows.length > 1) {
      final keys = psRows.first.map((e) => _parseField(e?.value)).toList();
      for (var i = 1; i < psRows.length; i++) {
        final values = psRows[i].map((e) => _parseField(e?.value)).toList();
        final map = Map.fromIterables(keys, values);
        await _paymentStatusDao.insertOrUpdateFromMap(map);
      }
    }
    // Restore Projections
    final projectionsSheet = excel['Projections'];
    final projRows = projectionsSheet.rows;
    if (projRows.length > 1) {
      final keys = projRows.first.map((e) => _parseField(e?.value)).toList();
      for (var i = 1; i < projRows.length; i++) {
        final values = projRows[i].map((e) => _parseField(e?.value)).toList();
        final map = Map.fromIterables(keys, values);
        await _projectionsDao.insertOrUpdateFromMap(map);
      }
    }
    // Restore Income
    final incomeSheet = excel['Income'];
    final incomeRows = incomeSheet.rows;
    if (incomeRows.length > 1) {
      final keys = incomeRows.first.map((e) => _parseField(e?.value)).toList();
      for (var i = 1; i < incomeRows.length; i++) {
        final values = incomeRows[i].map((e) => _parseField(e?.value)).toList();
        final map = Map.fromIterables(keys, values);
        await _incomeDao.insertOrUpdateFromMap(map);
      }
    }
    // Restore Upcoming Payments
    final upcomingSheet = excel['Upcoming Payments'];
    final upRows = upcomingSheet.rows;
    if (upRows.length > 1) {
      final keys = upRows.first.map((e) => _parseField(e?.value)).toList();
      for (var i = 1; i < upRows.length; i++) {
        final values = upRows[i].map((e) => _parseField(e?.value)).toList();
        final map = Map.fromIterables(keys, values);
        await _upcomingPaymentsDao.insertOrUpdateFromMap(map);
      }
    }
  }
}