import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_list.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await Provider.of<TaskProvider>(context, listen: false).initTasks();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taskify'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Completed', icon: Icon(Icons.task_alt)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(taskProvider.error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            taskProvider.clearError();
                            _loadTasks();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Pending Tasks
                    TaskList(
                      tasks: taskProvider.pendingTasks,
                      emptyMessage: 'No pending tasks. Add a new task to get started!',
                      onTap: (task) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(taskId: task.id),
                        ),
                      ),
                    ),
                    // Completed Tasks
                    TaskList(
                      tasks: taskProvider.completedTasks,
                      emptyMessage: 'No completed tasks yet. Complete a task to see it here!',
                      onTap: (task) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(taskId: task.id),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTaskScreen()),
        ),
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
