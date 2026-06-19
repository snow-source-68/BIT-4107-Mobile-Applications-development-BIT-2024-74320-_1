import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
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

  Future _createDB(Database db, int version) async {
    // Create Student Table
    await db.execute('''
      CREATE TABLE Student (
        student_id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        course_code TEXT NOT NULL
      )
    ''');

    // Create Attendance Log Table
    await db.execute('''
      CREATE TABLE Attendance (
        log_id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL,
        session_date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES Student (student_id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}