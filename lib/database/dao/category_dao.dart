import '../database_helper.dart';

class CategoryDao {
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await DatabaseHelper.database;
    return db.query(DatabaseHelper.tableCategory);
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await DatabaseHelper.database;
    return db.insert(DatabaseHelper.tableCategory, category);
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    final db = await DatabaseHelper.database;
    return db.update(
      DatabaseHelper.tableCategory,
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await DatabaseHelper.database;
    return db.delete(
      DatabaseHelper.tableCategory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final db = await DatabaseHelper.database;
    return db.query(
      DatabaseHelper.tableCategory,
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<void> insertOrUpdateFromMap(Map map) async {
    final db = await DatabaseHelper.database;
    final id = map['id'];
    final existing = await db.query(DatabaseHelper.tableCategory, where: 'id = ?', whereArgs: [id]);
    if (existing.isEmpty) {
      await db.insert(DatabaseHelper.tableCategory, Map<String, dynamic>.from(map));
    } else {
      await db.update(DatabaseHelper.tableCategory, Map<String, dynamic>.from(map), where: 'id = ?', whereArgs: [id]);
    }
  }
}
