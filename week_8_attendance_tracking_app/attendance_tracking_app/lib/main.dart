import 'package:flutter/material.dart';

void main() {
  runApp(const AttendanceTrackingApp());
}

// Global Application Root
class AttendanceTrackingApp extends StatelessWidget {
  const AttendanceTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Tracking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StudentInputPage(),
    );
  }
}

// Main Student Input UI Screen
class StudentInputPage extends StatefulWidget {
  const StudentInputPage({super.key});

  @override
  State<StudentInputPage> createState() => _StudentInputPageState();
}

class _StudentInputPageState extends State<StudentInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _validator = FormValidator();
  
  // Controllers to capture input data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regController = TextEditingController();

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      // Process and save your SQLite record here
      
      // This will now execute perfectly without crashing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student Record Added Successfully")),
      );

      // Optional: Clear fields after successful save
      _nameController.clear();
      _regController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance Entry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: _validator.validateStudentName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _regController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                    hintText: 'e.g., BIT/YYYY/ID',
                  ),
                  validator: _validator.validateRegistrationNumber,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Student Record',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Class-based Input Validation Handler
class FormValidator {
  String? validateStudentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Student name cannot be empty";
    }
    if (value.trim().length < 3) {
      return "Name must be at least 3 characters long";
    }
    return null;
  }

  String? validateRegistrationNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Registration number is required";
    }
    
    RegExp regExp = RegExp(r'^BIT/\d{4}/\d+$');
    if (!regExp.hasMatch(value.trim())) {
      return "Invalid format. Use BIT/YYYY/ID";
    }
    return null;
  }
}