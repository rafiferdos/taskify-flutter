import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate;
  bool _isCompleted = false;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadTaskData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTaskData() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task = taskProvider.tasks.firstWhere((task) => task.id == widget.taskId);
    
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedDueDate = task.dueDate;
    _isCompleted = task.isCompleted;
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _selectedDueDate) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final task = taskProvider.tasks.firstWhere((task) => task.id == widget.taskId);
        
        final updatedTask = task.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDueDate,
          isCompleted: _isCompleted,
        );
        
        await taskProvider.updateTask(updatedTask);
        
        if (mounted) {
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update task: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteTask() async {
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
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<TaskProvider>(context, listen: false).deleteTask(widget.taskId);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete task: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
            ),
          ],
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final task = taskProvider.tasks.firstWhere(
            (task) => task.id == widget.taskId,
            orElse: () => Task(
              id: widget.taskId,
              title: 'Task not found',
              description: '',
              createdAt: DateTime.now(),
            ),
          );

          if (task.id != widget.taskId) {
            return const Center(child: Text('Task not found'));
          }

          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _isEditing
                      ? _buildEditForm()
                      : _buildTaskDetails(task),
                );
        },
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          ListTile(
            title: const Text('Due Date'),
            subtitle: Text(
              _selectedDueDate == null
                  ? 'No due date'
                  : 'Due on ${DateFormat('MMM d, yyyy').format(_selectedDueDate!)}',
            ),
            trailing: Icon(
              Icons.calendar_today,
              color: Theme.of(context).primaryColor,
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4.0),
            ),
            onTap: () => _selectDueDate(context),
          ),
          const SizedBox(height: 16.0),
          SwitchListTile(
            title: const Text('Task Completed'),
            value: _isCompleted,
            onChanged: (value) {
              setState(() {
                _isCompleted = value;
              });
            },
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _loadTaskData(); // Reset form data
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateTask,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetails(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2.0,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Chip(
                  label: Text(
                    task.isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      color: task.isCompleted ? Colors.white : Colors.black,
                    ),
                  ),
                  backgroundColor: task.isCompleted 
                      ? Colors.green 
                      : Colors.amber,
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2.0,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  task.description,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2.0,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Information',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Created'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(task.createdAt)),
                  dense: true,
                ),
                if (task.dueDate != null)
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Due Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(task.dueDate!)),
                    dense: true,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).toggleTaskStatus(task.id);
            },
            icon: Icon(task.isCompleted ? Icons.refresh : Icons.check),
            label: Text(task.isCompleted ? 'Mark as Pending' : 'Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: task.isCompleted ? Colors.grey : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
        ),
      ],
    );
  }
}
