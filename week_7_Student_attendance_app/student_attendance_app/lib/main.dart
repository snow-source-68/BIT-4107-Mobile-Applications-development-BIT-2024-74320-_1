import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ==========================================
// DATABASE HELPER (Relational SQLite Engine)
// ==========================================
class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = p.join(await getDatabasesPath(), 'attendance_system.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Students Table
        await db.execute('''
          CREATE TABLE students (
            student_id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            course TEXT NOT NULL
          )
        ''');
        // Attendance Table (Relational Reference)
        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id TEXT,
            date TEXT NOT NULL,
            status INTEGER NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (student_id) ON DELETE CASCADE
          )
        ''');
        
        // Seed initial data
        await db.insert('students', {'student_id': 'BIT4102-2026', 'name': 'Maina Kinya', 'course': 'BIT'});
        await db.insert('students', {'student_id': 'BIT4102-0092', 'name': 'Alex Munene', 'course': 'BIT'});
        await db.insert('students', {'student_id': 'BIT4102-0115', 'name': 'Jane Wanjiku', 'course': 'BIT'});
      },
    );
  }
}

// ==========================================
// HOME SCREEN (Navigation Hub)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ChecklistScreen(),
    const DashboardScreen(),
    const ManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fact_check), label: 'Roll Call'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Students'),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 1: ATTENDANCE CHECKLIST
// ==========================================
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<Map<String, dynamic>> _students = [];
  Map<String, bool> _attendanceStatus = {};
  final String _currentDate = DateTime.now().toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final db = await DBHelper.database;
    final studentsData = await db.query('students');
    
    // Check if attendance records exist for today
    final existingAttendance = await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [_currentDate],
    );

    Map<String, bool> tempStatus = {};
    for (var student in studentsData) {
      String id = student['student_id'].toString();
      // Default to absent (false)
      tempStatus[id] = false;
    }

    // Overwrite with saved entries if found
    for (var record in existingAttendance) {
      tempStatus[record['student_id'].toString()] = record['status'] == 1;
    }

    setState(() {
      _students = studentsData;
      _attendanceStatus = tempStatus;
    });
  }

  Future<void> _toggleAttendance(String studentId, bool? checked) async {
    final db = await DBHelper.database;
    bool statusValue = checked ?? false;

    setState(() {
      _attendanceStatus[studentId] = statusValue;
    });

    // Verify if entry already exists in the local database
    final existing = await db.query(
      'attendance',
      where: 'student_id = ? AND date = ?',
      whereArgs: [studentId, _currentDate],
    );

    if (existing.isEmpty) {
      await db.insert('attendance', {
        'student_id': studentId,
        'date': _currentDate,
        'status': statusValue ? 1 : 0
      });
    } else {
      await db.update(
        'attendance',
        {'status': statusValue ? 1 : 0},
        where: 'student_id = ? AND date = ?',
        whereArgs: [studentId, _currentDate],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roll Call ($_currentDate)'),
        backgroundColor: Colors.teal,
      ),
      body: _students.isEmpty
          ? const Center(child: Text('No students registered.'))
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final String id = student['student_id'];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: CheckboxListTile(
                    title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${student['student_id']} | ${student['course']}'),
                    value: _attendanceStatus[id] ?? false,
                    onChanged: (val) => _toggleAttendance(id, val),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// SCREEN 2: METRICS & EXPORT DASHBOARD
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _reportData = [];

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  Future<void> _calculateMetrics() async {
    final db = await DBHelper.database;
    // Query aggregating database execution data
    final result = await db.rawQuery('''
      SELECT 
        s.student_id, 
        s.name, 
        COUNT(a.id) as total_sessions,
        SUM(CASE WHEN a.status = 1 THEN 1 ELSE 0 END) as present_sessions
      FROM students s
      LEFT JOIN attendance a ON s.student_id = a.student_id
      GROUP BY s.student_id
    ''');

    setState(() {
      _reportData = result;
    });
  }

  Future<void> _exportData() async {
    // Generate JSON Export Payload mirroring requirements
    List<Map<String, dynamic>> structuralExport = [];
    for (var row in _reportData) {
      double rate = row['total_sessions'] == 0 
          ? 0.0 
          : (row['present_sessions'] as int) / (row['total_sessions'] as int) * 100;
      
      structuralExport.add({
        "id": row['student_id'],
        "name": row['name'],
        "attendance_rate": "${rate.toStringAsFixed(1)}%"
      });
    }

    String jsonPayload = const JsonEncoder.withIndent('  ').convert(structuralExport);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Structured JSON Export Out'),
        content: SingleChildScrollView(
          child: Text(
            jsonPayload,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Dismiss'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Metrics'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: _exportData,
            tooltip: 'Export JSON Data',
          )
        ],
      ),
      body: _reportData.isEmpty
          ? const Center(child: Text('No statistical metrics compiled yet.'))
          : ListView.builder(
              itemCount: _reportData.length,
              itemBuilder: (context, index) {
                final row = _reportData[index];
                int total = row['total_sessions'] ?? 0;
                int present = row['present_sessions'] ?? 0;
                double percentage = total == 0 ? 0.0 : (present / total) * 100;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: percentage >= 75 ? Colors.green : Colors.orange,
                      child: Text('${percentage.toStringAsFixed(0)}%'),
                    ),
                    title: Text(row['name']),
                    subtitle: Text('ID: ${row['student_id']}'),
                    trailing: Text('$present / $total Days'),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// SCREEN 3: STUDENT REGISTRATION
// ==========================================
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  List<Map<String, dynamic>> _allStudents = [];

  @override
  void initState() {
    super.initState();
    _refreshStudents();
  }

  Future<void> _refreshStudents() async {
    final db = await DBHelper.database;
    final data = await db.query('students');
    setState(() {
      _allStudents = data;
    });
  }

  Future<void> _addStudent() async {
    if (_idController.text.isEmpty || _nameController.text.isEmpty || _courseController.text.isEmpty) {
      return;
    }
    final db = await DBHelper.database;
    try {
      await db.insert('students', {
        'student_id': _idController.text.trim(),
        'name': _nameController.text.trim(),
        'course': _courseController.text.trim(),
      });
      _idController.clear();
      _nameController.clear();
      _courseController.clear();
      _refreshStudents();
    } catch (e) {if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Student ID must be unique!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Registry'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            key: const ValueKey('reg_form'),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(controller: _idController, decoration: const InputDecoration(labelText: 'Admission Number')),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                    TextField(controller: _courseController, decoration: const InputDecoration(labelText: 'Course Component')),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addStudent,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Register Student'),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allStudents.length,
              itemBuilder: (context, index) {
                final s = _allStudents[index];
                return ListTile(
                  leading: const Icon(Icons.account_circle, size: 40),
                  title: Text(s['name']),
                  subtitle: Text('${s['student_id']} [${s['course']}]'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class AppText extends StatelessWidget {
  final String text;
  const AppText(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text);
}