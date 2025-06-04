import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static const _databaseName = 'finance_management.db';
  static const _databaseVersion = 1;

  static const tableCategory = 'category';
  static const tablePaymentStatus = 'payment_status';
  static const tableIncome = 'income';
  static const tableProjections = 'projections';
  static const tableUpcomingPayments = 'upcoming_payments';

  static Database? _database;

  static void initializeSqfliteFactory() {
    databaseFactory = databaseFactoryFfi;
    log('Sqflite factory initialized');
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategory (
        id INTEGER PRIMARY KEY,
        type TEXT,
        name TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePaymentStatus (
        id INTEGER PRIMARY KEY,
        type TEXT,
        name TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableIncome (
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        description TEXT,
        income_date TEXT,
        projected_amount REAL,
        amount_paid REAL,
        payment_status_id INTEGER,
        remarks TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableProjections (
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        description TEXT,
        projection_date TEXT,
        projected_amount REAL,
        amount_paid REAL,
        payment_status_id INTEGER,
        remarks TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableUpcomingPayments (
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        description TEXT,
        upcoming_from_date TEXT,
        upcoming_to_date TEXT,
        renewal_date TEXT,
        projected_amount REAL,
        amount_paid REAL,
        payment_status_id INTEGER,
        remarks TEXT
      )
    ''');
  }
}
