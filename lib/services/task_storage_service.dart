import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks';

  // Save tasks to local storage
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, json.encode(tasksJson));
  }

  // Load tasks from local storage
  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksString = prefs.getString(_tasksKey);
      
      if (tasksString == null || tasksString.isEmpty) {
        return [];
      }
      
      final List<dynamic> tasksJson = json.decode(tasksString);
      return tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      // If there's an error loading tasks, return an empty list
      return [];
    }
  }

  // Clear all tasks from local storage
  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}
