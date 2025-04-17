import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskApiService {
  // Using JSONPlaceholder API for demo purposes
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Fetch all tasks
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/todos'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Convert JSONPlaceholder todos to our Task model
        return data.map((item) => Task(
          id: item['id'].toString(),
          title: item['title'],
          description: '', // JSONPlaceholder doesn't have descriptions
          isCompleted: item['completed'],
          createdAt: DateTime.now(), // Mock creation date
          dueDate: null, // Mock due date
        )).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  // Create a new task
  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Update a task
  Future<Task> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/todos/$id'));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
