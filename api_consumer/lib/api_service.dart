import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // We use a safe, free public REST API meant for university students to test networking
  final String url = "https://jsonplaceholder.typicode.com/users";

  Future<List<dynamic>> fetchUsers() async {
    try {
      // Perform the HTTP GET request as explained in your lesson slides
      final response = await http.get(Uri.parse(url));

      // Check HTTP Status Codes
      if (response.statusCode == 200) {
        // 200 means Success! Decode the JSON array string into a usable Dart list
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception("Error 404: The API endpoint was not found.");
      } else if (response.statusCode == 500) {
        throw Exception("Error 500: Internal Server Error on the public web host.");
      } else {
        throw Exception("Failed to load users. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      // Catches loss of internet connectivity or timeouts
      throw Exception("Network Error: Make sure your computer has an active internet connection.");
    }
  }
}