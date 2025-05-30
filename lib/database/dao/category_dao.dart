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
}
