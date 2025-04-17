# Taskify

# Taskify - A Flutter Task Management Application

![Taskify Logo](https://img.shields.io/badge/Taskify-Task%20Management-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📱 Overview

Taskify is a feature-rich Flutter task management application designed to help users organize their daily tasks efficiently. The app provides a clean, intuitive interface for creating, managing, and tracking tasks with features like due dates, task completion status, and more. Taskify demonstrates best practices in Flutter development including state management, API integration, local data persistence, and multi-page navigation.

## ✨ Features

- **Task Management**: Create, view, update, and delete tasks (CRUD operations)
- **Task Organization**: Separate views for pending and completed tasks
- **Due Date Tracking**: Set and monitor task due dates
- **Data Persistence**: Local storage of tasks with shared preferences
- **API Integration**: Synchronization with a remote API
- **Beautiful UI**: Modern Material Design with intuitive user experience
- **Stateful Architecture**: Robust state management with Provider

## 📋 Table of Contents

- [Installation](#-installation)
- [Project Structure](#-project-structure)
- [Screens](#-screens)
- [Core Features Implementation](#-core-features-implementation)
- [State Management](#-state-management)
- [Data Handling](#-data-handling)
- [API Integration](#-api-integration)
- [Collaborative Development](#-collaborative-development)
- [Future Enhancements](#-future-enhancements)
- [License](#-license)

## 🚀 Installation

Follow these step-by-step instructions to set up the Taskify application on your local machine:

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio or VS Code with Flutter extension
- An emulator or physical device for testing

### Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/taskify.git
   cd taskify
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**

   ```bash
   flutter run
   ```

## 📁 Project Structure

The project follows a well-organized structure to maintain code clarity and separation of concerns:

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   └── task.dart          # Task model definition
├── providers/             # State management
│   └── task_provider.dart # Task state management
├── screens/               # Application screens
│   ├── add_task_screen.dart    # Screen for adding new tasks
│   ├── home_screen.dart        # Main screen with task lists
│   ├── splash_screen.dart      # Initial loading screen
│   └── task_detail_screen.dart # Detailed task view screen
├── services/              # External services
│   ├── task_api_service.dart     # API communication service
│   └── task_storage_service.dart # Local storage service
├── utils/                 # Helper utilities
│   └── task_utils.dart    # Task-related helper functions
└── widgets/               # Reusable UI components
    ├── task_list.dart        # Task list widget
    └── taskify_app_bar.dart  # Custom app bar widget
```

## 📱 Screens

### Splash Screen

- Initial loading screen displaying the Taskify logo
- Preloads task data before navigating to the home screen
- Features smooth fade-in animations for a polished user experience

### Home Screen

- Main screen with tabs for "Pending" and "Completed" tasks
- Floating action button to add new tasks
- Task list with swipeable actions for quick task management

### Add Task Screen

- Form to create new tasks with validation
- Fields for title, description, and due date selection
- Date picker for selecting due dates

### Task Detail Screen

- Detailed view of selected task information
- Option to edit task details
- Button to toggle task completion status
- Delete functionality with confirmation

## 💻 Core Features Implementation

### Task Model

The `Task` class is the foundation of our data structure and includes:

```dart
class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;

  // Methods for JSON conversion and object manipulation
  // ...
}
```

### CRUD Operations

#### Create

New tasks are created through the `addTask` method in the TaskProvider:

```dart
Future<void> addTask(String title, String description, DateTime? dueDate) async {
  // Generate unique ID for the task
  // Add to local list
  // Save to API and local storage
}
```

#### Read

Tasks are retrieved and displayed in the task list:

```dart
// Fetch tasks from API and local storage
Future<void> initTasks() async {
  // Load from local storage first for quick display
  // Then fetch from API for updated data
}
```

#### Update

Task updates include editing task details or toggling completion status:

```dart
Future<void> updateTask(Task updatedTask) async {
  // Update in local list
  // Save changes to API and local storage
}

Future<void> toggleTaskStatus(String id) async {
  // Toggle completion status of a specific task
}
```

#### Delete

Tasks can be removed with confirmation:

```dart
Future<void> deleteTask(String id) async {
  // Remove from local list
  // Delete from API and update local storage
}
```

## 📊 State Management

Taskify uses the Provider package for state management, which offers a clean and efficient way to manage app state:

- **TaskProvider**: Centralized state management for all task-related operations
- **ChangeNotifier**: Notifies listeners when the task list changes
- **Consumer**: Rebuilds UI components when the state changes

Example of state consumption:

```dart
Consumer<TaskProvider>(
  builder: (context, taskProvider, child) {
    return TaskList(
      tasks: taskProvider.pendingTasks,
      // Other properties...
    );
  },
)
```

## 💾 Data Handling

Taskify implements two-layer data handling for optimal performance and offline capability:

### Local Storage

The `TaskStorageService` manages local data persistence using SharedPreferences:

```dart
// Save tasks locally
Future<void> saveTasks(List<Task> tasks) async {
  // Convert tasks to JSON and store in SharedPreferences
}

// Load tasks from local storage
Future<List<Task>> loadTasks() async {
  // Retrieve and parse tasks from SharedPreferences
}
```

### Memory Cache

The `TaskProvider` maintains an in-memory list of tasks for quick access and manipulation:

```dart
List<Task> _tasks = [];
List<Task> get tasks => _tasks;
List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
```

## 🌐 API Integration

Taskify integrates with a REST API (JSONPlaceholder for demo purposes) to demonstrate cloud synchronization:

```dart
class TaskApiService {
  // Base URL for API endpoints
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Methods for API communication (fetch, create, update, delete)
  // ...
}
```

API operations include:

- `fetchTasks()`: Retrieve all tasks from the server
- `createTask(Task task)`: Send new task to the server
- `updateTask(Task task)`: Update existing task on the server
- `deleteTask(String id)`: Remove task from the server

## 👥 Collaborative Development

Taskify is designed with collaborative development in mind, ideal for group projects:

### GitHub Collaboration

- **Central Repository**: Maintain a single GitHub repository for the project
- **Branch-Based Development**: Each team member works on features in separate branches
- **Pull Requests**: Code review and merging through pull requests
- **Issue Tracking**: Use GitHub issues to track tasks and bugs

### Code Organization

- **Modular Structure**: Components are separated into their own files and folders
- **Clear Dependencies**: Each file explicitly imports its dependencies
- **Separation of Concerns**: UI, business logic, and data access are separated

## 🚧 Future Enhancements

Taskify can be extended with these additional features:

1. **User Authentication**: Login and registration functionality
2. **Task Categories**: Organize tasks by categories or projects
3. **Task Search & Filters**: Advanced filtering options
4. **Notifications**: Reminders for upcoming tasks
5. **Cloud Sync**: Real-time synchronization across devices
6. **Dark Mode**: Theme customization
7. **Data Analytics**: Task completion statistics and insights

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Developed with ❤️ by Rafi Ferdos - using Flutter
