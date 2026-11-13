import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService();
  final _dialogFormKey = GlobalKey<FormState>();
  final List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (_authService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    } else {
      _loadTasks();
    }
  }

  Future<void> _loadTasks() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final tasks = await _dbService.getTasks();
      if (mounted) {
        setState(() {
          _tasks
            ..clear()
            ..addAll(tasks);
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível carregar as tarefas: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleTask(TaskModel task, bool? isDone) async {
    if (isDone == null) {
      return;
    }
    try {
      await _dbService.updateTask(task, isDone: isDone);
      await _loadTasks();
    } catch (error) {
      _showError('Não foi possível atualizar a tarefa: $error');
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    try {
      await _dbService.deleteTask(task.id);
      await _loadTasks();
    } catch (error) {
      _showError('Não foi possível excluir a tarefa: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showTaskDialog({TaskModel? task}) async {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController =
        TextEditingController(text: task?.description ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(task == null ? 'Nova tarefa' : 'Editar tarefa'),
          content: Form(
            key: _dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um título.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!_dialogFormKey.currentState!.validate()) {
                  return;
                }

                try {
                  if (task == null) {
                    await _dbService.createTask(
                      titleController.text,
                      descriptionController.text,
                    );
                  } else {
                    await _dbService.updateTask(
                      task,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                    );
                  }
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } catch (error) {
                  _showError('Não foi possível salvar a tarefa: $error');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (saved == true) {
      await _loadTasks();
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      _showError('Não foi possível sair da conta: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(
                  child: Text('Você ainda não tem tarefas.'),
                )
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return TaskTile(
                      task: task,
                      onToggle: (isDone) => _toggleTask(task, isDone),
                      onEdit: () => _showTaskDialog(task: task),
                      onDelete: () => _deleteTask(task),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa'),
      ),
    );
  }
}