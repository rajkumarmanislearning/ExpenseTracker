import '../database_helper.dart';

class IncomeDao {
  Future<List<Map<String, dynamic>>> getIncomeByMonth(String month) async {
    final db = await DatabaseHelper.database;
    return db.query(
      DatabaseHelper.tableIncome,
      where: 'strftime("%Y-%m", income_date) = ?',
      whereArgs: [month],
    );
  }

  Future<int> insertIncome(Map<String, dynamic> income) async {
    final db = await DatabaseHelper.database;
    return db.insert(DatabaseHelper.tableIncome, income);
  }

  Future<int> updateIncome(Map<String, dynamic> income) async {
    final db = await DatabaseHelper.database;
    return db.update(
      DatabaseHelper.tableIncome,
      income,
      where: 'id = ?',
      whereArgs: [income['id']],
    );
  }

  Future<int> deleteIncome(int id) async {
    final db = await DatabaseHelper.database;
    return db.delete(
      DatabaseHelper.tableIncome,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllIncome() async {
    final db = await DatabaseHelper.database;
    return db.query(DatabaseHelper.tableIncome);
  }

  Future<void> insertOrUpdateFromMap(Map map) async {
    final db = await DatabaseHelper.database;
    final id = map['id'];
    final existing = await db.query(DatabaseHelper.tableIncome, where: 'id = ?', whereArgs: [id]);
    if (existing.isEmpty) {
      await db.insert(DatabaseHelper.tableIncome, Map<String, dynamic>.from(map));
    } else {
      await db.update(DatabaseHelper.tableIncome, Map<String, dynamic>.from(map), where: 'id = ?', whereArgs: [id]);
    }
  }
}
