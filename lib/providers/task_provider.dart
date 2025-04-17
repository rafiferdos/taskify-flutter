import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/task_api_service.dart';
import '../services/task_storage_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  
  // Services
  final TaskApiService _apiService = TaskApiService();
  final TaskStorageService _storageService = TaskStorageService();
  
  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  
  // Initialize tasks from API and local storage
  Future<void> initTasks() async {
    _setLoading(true);
    try {
      // First try to load from local storage for instant UI display
      final localTasks = await _storageService.loadTasks();
      if (localTasks.isNotEmpty) {
        _tasks = localTasks;
        notifyListeners();
      }
      
      // Then fetch from API to get updated data
      final apiTasks = await _apiService.fetchTasks();
      _tasks = apiTasks;
      
      // Save the updated tasks to local storage
      await _storageService.saveTasks(_tasks);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      // If API fetch fails, use local data if available
      if (_tasks.isEmpty) {
        _setError('Failed to load tasks. Please check your connection.');
      }
      _setLoading(false);
    }
  }
  
  // Add a new task
  Future<void> addTask(String title, String description, DateTime? dueDate) async {
    _setLoading(true);
    try {
      final newTask = Task(
        id: const Uuid().v4(), // Generate unique ID
        title: title,
        description: description,
        createdAt: DateTime.now(),
        dueDate: dueDate,
      );
      
      // Optimistically update UI
      _tasks.add(newTask);
      notifyListeners();
      
      // Save to API
      await _apiService.createTask(newTask);
      
      // Update local storage
      await _storageService.saveTasks(_tasks);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to add task: ${e.toString()}');
      _setLoading(false);
    }
  }
  
  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    _setLoading(true);
    try {
      // Optimistically update UI
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
        
        // Save to API
        await _apiService.updateTask(updatedTask);
        
        // Update local storage
        await _storageService.saveTasks(_tasks);
      }
      _setLoading(false);
    } catch (e) {
      _setError('Failed to update task: ${e.toString()}');
      _setLoading(false);
    }
  }
  
  // Toggle task completion status
  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    }
  }
  
  // Delete a task
  Future<void> deleteTask(String id) async {
    _setLoading(true);
    try {
      // Optimistically update UI
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
      
      // Delete from API
      await _apiService.deleteTask(id);
      
      // Update local storage
      await _storageService.saveTasks(_tasks);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to delete task: ${e.toString()}');
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
