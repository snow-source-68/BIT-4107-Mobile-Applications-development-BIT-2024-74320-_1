import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Registration',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const StudentRegistrationScreen(),
    );
  }
}

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final List<Map<String, dynamic>> _students = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  Future<void> _refreshStudentList() async {
    final data = await DatabaseHelper.instance.queryAllStudents();
    setState(() {
      _students.clear();
      _students.addAll(data);
    });
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty || _courseController.text.isEmpty) return;

    if (_selectedId == null) {
      await DatabaseHelper.instance.insertStudent(
        _nameController.text,
        _courseController.text,
      );
    } else {
      await DatabaseHelper.instance.updateStudent(
        _selectedId!,
        _nameController.text,
        _courseController.text,
      );
      _selectedId = null;
    }

    _nameController.clear();
    _courseController.clear();
    _refreshStudentList();
  }

  void _editStudent(Map<String, dynamic> student) {
    setState(() {
      _selectedId = student['id'];
      _nameController.text = student['name'];
      _courseController.text = student['course'];
    });
  }

  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _refreshStudentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text(_selectedId == null ? 'Register Student' : 'Update Details'),
            ),
            const Divider(height: 30),
            const Text('Registered Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _students.isEmpty
                  ? const Center(child: Text('No records found.'))
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(student['name']),
                            subtitle: Text(student['course']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editStudent(student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteStudent(student['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}