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
}
