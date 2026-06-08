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
      // Requirement: Change App Title
      title: 'Week 1 Assignment', 
      home: Scaffold(
        // Requirement: Change Background Color
        backgroundColor: Colors.amber[100], 
        appBar: AppBar(
          title: const Text('My First Flutter App'),
          backgroundColor: Colors.amber,
        ),
        body: const Center(
          child: Text(
            'Hello World!',
            style: TextStyle(
              // Requirement: Change Font Size
              fontSize: 36.0, 
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}