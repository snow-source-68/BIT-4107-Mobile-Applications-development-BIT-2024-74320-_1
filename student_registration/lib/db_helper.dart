import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // CREATE TABLE
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        course TEXT NOT NULL
      )
    ''');
  }

  // INSERT
  Future<int> insertStudent(String name, String course) async {
    final db = await instance.database;
    return await db.insert('Students', {'name': name, 'course': course});
  }

  // RETRIEVE
  Future<List<Map<String, dynamic>>> queryAllStudents() async {
    final db = await instance.database;
    return await db.query('Students');
  }

  // UPDATE
  Future<int> updateStudent(int id, String name, String course) async {
    final db = await instance.database;
    return await db.update(
      'Students',
      {'name': name, 'course': course},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete('Students', where: 'id = ?', whereArgs: [id]);
  }
}