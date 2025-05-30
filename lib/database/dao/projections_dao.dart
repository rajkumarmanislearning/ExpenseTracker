import '../database_helper.dart';

class ProjectionsDao {
  Future<List<Map<String, dynamic>>> getProjectionsByMonth(String month) async {
    final db = await DatabaseHelper.database;
    return db.query(
      DatabaseHelper.tableProjections,
      where: 'strftime("%Y-%m", projection_date) = ?',
      whereArgs: [month],
    );
  }

  Future<int> insertProjection(Map<String, dynamic> projection) async {
    final db = await DatabaseHelper.database;
    return db.insert(DatabaseHelper.tableProjections, projection);
  }

  Future<int> updateProjection(Map<String, dynamic> projection) async {
    final db = await DatabaseHelper.database;
    return db.update(
      DatabaseHelper.tableProjections,
      projection,
      where: 'id = ?',
      whereArgs: [projection['id']],
    );
  }

  Future<int> deleteProjection(int id) async {
    final db = await DatabaseHelper.database;
    return db.delete(
      DatabaseHelper.tableProjections,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
