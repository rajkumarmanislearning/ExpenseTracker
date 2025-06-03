import '../database_helper.dart';

class UpcomingPaymentsDao {
  Future<List<Map<String, dynamic>>> getUpcomingPaymentsByMonth(String month) async {
    final db = await DatabaseHelper.database;
    return db.query(
      DatabaseHelper.tableUpcomingPayments,
      where: 'strftime("%Y-%m", upcoming_from_date) = ?',
      whereArgs: [month],
    );
  }

  Future<int> insertUpcomingPayment(Map<String, dynamic> upcomingPayment) async {
    final db = await DatabaseHelper.database;
    return db.insert(DatabaseHelper.tableUpcomingPayments, upcomingPayment);
  }

  Future<int> updateUpcomingPayment(Map<String, dynamic> upcomingPayment) async {
    final db = await DatabaseHelper.database;
    return db.update(
      DatabaseHelper.tableUpcomingPayments,
      upcomingPayment,
      where: 'id = ?',
      whereArgs: [upcomingPayment['id']],
    );
  }

  Future<int> deleteUpcomingPayment(int id) async {
    final db = await DatabaseHelper.database;
    return db.delete(
      DatabaseHelper.tableUpcomingPayments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllUpcomingPayments() async {
    final db = await DatabaseHelper.database;
    return db.query(DatabaseHelper.tableUpcomingPayments);
  }

  Future<void> insertOrUpdateFromMap(Map map) async {
    final db = await DatabaseHelper.database;
    final id = map['id'];
    final existing = await db.query(DatabaseHelper.tableUpcomingPayments, where: 'id = ?', whereArgs: [id]);
    if (existing.isEmpty) {
      await db.insert(DatabaseHelper.tableUpcomingPayments, Map<String, dynamic>.from(map));
    } else {
      await db.update(DatabaseHelper.tableUpcomingPayments, Map<String, dynamic>.from(map), where: 'id = ?', whereArgs: [id]);
    }
  }
}
