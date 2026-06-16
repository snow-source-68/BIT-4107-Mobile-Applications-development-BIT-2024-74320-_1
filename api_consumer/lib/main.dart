import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const ApiConsumerApp());
}

class ApiConsumerApp extends StatelessWidget {
  const ApiConsumerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Consumer App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _loadedUsers;

  @override
  void initState() {
    super.initState();
    // Trigger the background HTTP download immediately when the app launches
    _loadedUsers = _apiService.fetchUsers();
  }

  // Allow manual refreshing of live data
  void _refreshData() {
    setState(() {
      _loadedUsers = _apiService.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Live User Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      // FutureBuilder automatically handles the background asynchronous states
      body: FutureBuilder<List<dynamic>>(
        future: _loadedUsers,
        builder: (context, snapshot) {
          // State 1: The web data is still downloading from the internet
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // State 2: A network error or status code failure occurred
          else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          
          // State 3: Data successfully downloaded and parsed!
          else if (snapshot.hasData) {
            final users = snapshot.data!;
            
            // Flutter's ListView.builder operates exactly like the requested "RecyclerView"
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user['id'].toString()),
                    ),
                    title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Email: ${user['email']}\nWebsite: ${user['website']}'),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }
}