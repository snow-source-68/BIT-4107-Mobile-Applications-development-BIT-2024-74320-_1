import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Week 2 Assignment',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StudentManagementApp(),
    );
  }
}

class StudentManagementApp extends StatefulWidget {
  const StudentManagementApp({super.key});

  @override
  State<StudentManagementApp> createState() => _StudentManagementAppState();
}

class _StudentManagementAppState extends State<StudentManagementApp> {
  // Keeps track of whether to show Login screen or Registration screen
  bool isLoginPage = true; 

  // Controllers to capture text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  void _togglePage() {
    setState(() {
      isLoginPage = !isLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isLoginPage ? 'Student Login' : 'Student Registration'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: isLoginPage ? _buildLoginView() : _buildRegisterView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 1. LOGIN SCREEN INTERFACE
  Widget _buildLoginView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Welcome Back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username / Reg Number', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50), 
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful! (Simulated)')),
            );
          },
          child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _togglePage,
          child: const Text('Don\'t have an account? Register here'),
        ),
      ],
    );
  }

  // 2. REGISTRATION SCREEN INTERFACE
  Widget _buildRegisterView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Register New Student', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _regNumberController,
          decoration: const InputDecoration(labelText: 'Registration Number', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _courseController,
          decoration: const InputDecoration(labelText: 'Course / Program', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50), 
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (_nameController.text.isNotEmpty && _regNumberController.text.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registered: ${_nameController.text}')),
              );
              // Clear fields and toggle back to login screen
              _nameController.clear();
              _regNumberController.clear();
              _courseController.clear();
              _togglePage();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in required fields')),
              );
            }
          },
          child: const Text('Submit Registration', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _togglePage,
          child: const Text('Already registered? Login here'),
        ),
      ],
    );
  }
}