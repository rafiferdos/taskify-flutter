import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final String emptyMessage;
  final Function(Task) onTap;

  const TaskList({
    super.key,
    required this.tasks,
    required this.emptyMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskListItem(
          task: task,
          onTap: () => onTap(task),
        );
      },
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => taskProvider.toggleTaskStatus(task.id),
              backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              icon: task.isCompleted ? Icons.replay : Icons.check,
              label: task.isCompleted ? 'Pending' : 'Complete',
            ),
            SlidableAction(
              onPressed: (_) async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text('Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  taskProvider.deleteTask(task.id);
                }
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2.0,
          child: ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            onTap: onTap,
            leading: CircleAvatar(
              backgroundColor: task.isCompleted ? Colors.green : Colors.blue,
              child: Icon(
                task.isCompleted ? Icons.check : Icons.pending_actions,
                color: Colors.white,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (task.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate!)}',
                          style: TextStyle(
                            color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
                                ? Colors.red
                                : null,
                            fontWeight: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.green.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.isCompleted ? 'Completed' : 'Pending',
                style: TextStyle(
                  color: task.isCompleted ? Colors.green.shade800 : Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
