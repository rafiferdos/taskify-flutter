import 'package:intl/intl.dart';

class TaskUtils {
  // Format a date to a readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  // Check if a task is overdue
  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    return taskDueDate.isBefore(today);
  }
  
  // Get the remaining days until a task is due
  static String getDueStatus(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final difference = taskDueDate.difference(today).inDays;
    
    if (difference < 0) {
      return 'Overdue by ${-difference} day${-difference > 1 ? 's' : ''}';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }
  
  // Get a priority color based on due date
  static PriorityLevel getPriorityFromDueDate(DateTime? dueDate) {
    if (dueDate == null) return PriorityLevel.none;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final difference = taskDueDate.difference(today).inDays;
    
    if (difference < 0) {
      return PriorityLevel.high;
    } else if (difference <= 2) {
      return PriorityLevel.medium;
    } else {
      return PriorityLevel.low;
    }
  }
}

enum PriorityLevel {
  none,
  low,
  medium,
  high
}
