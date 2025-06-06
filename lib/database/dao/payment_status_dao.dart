import '../database_helper.dart';

class PaymentStatusDao {
  Future<List<Map<String, dynamic>>> getAllPaymentStatuses() async {
    final db = await DatabaseHelper.database;
    return db.query(DatabaseHelper.tablePaymentStatus);
  }

  Future<int> insertPaymentStatus(Map<String, dynamic> paymentStatus) async {
    final db = await DatabaseHelper.database;
    return db.insert(DatabaseHelper.tablePaymentStatus, paymentStatus);
  }

  Future<int> updatePaymentStatus(Map<String, dynamic> paymentStatus) async {
    final db = await DatabaseHelper.database;
    return db.update(
      DatabaseHelper.tablePaymentStatus,
      paymentStatus,
      where: 'id = ?',
      whereArgs: [paymentStatus['id']],
    );
  }

  Future<int> deletePaymentStatus(int id) async {
    final db = await DatabaseHelper.database;
    return db.delete(
      DatabaseHelper.tablePaymentStatus,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPaymentStatusesByType(String type) async {
    final db = await DatabaseHelper.database;
    return db.query(
      DatabaseHelper.tablePaymentStatus,
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<void> insertOrUpdateFromMap(Map map) async {
    final db = await DatabaseHelper.database;
    final id = map['id'];
    final existing = await db.query(DatabaseHelper.tablePaymentStatus, where: 'id = ?', whereArgs: [id]);
    if (existing.isEmpty) {
      await db.insert(DatabaseHelper.tablePaymentStatus, Map<String, dynamic>.from(map));
    } else {
      await db.update(DatabaseHelper.tablePaymentStatus, Map<String, dynamic>.from(map), where: 'id = ?', whereArgs: [id]);
    }
  }
}
