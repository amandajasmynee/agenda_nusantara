import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task_model.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String? _category;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _category = ModalRoute.of(context)?.settings.arguments as String?;
      _initialized = true;
    }
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks =
        await DatabaseHelper.instance.getAllTasks(category: _category);
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _toggleDone(TaskModel task) async {
    final newStatus = task.isDone == 0 ? 1 : 0;
    await DatabaseHelper.instance.updateTaskStatus(task.id!, newStatus);
    _loadTasks();
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Hapus "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTask(task.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas dihapus')),
      );
      _loadTasks();
    }
  }

  String? get _addTaskArgument => _category;

  String get _pageTitle {
    if (_category == 'important') return 'Tugas Penting';
    if (_category == 'regular') return 'Tugas Biasa';
    return 'Semua Tugas';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada tugas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return _TaskCard(
                        task: task,
                        onToggle: () => _toggleDone(task),
                        onDelete: () => _deleteTask(task),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/add-task',
            arguments: _addTaskArgument,
          );
          _loadTasks();
        },
        backgroundColor: const Color(0xFFCC0000),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ── Widget Task Card ─────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isDone == 1;
    final isImportant = task.category == 'important';
    final arrowColor = isImportant ? Colors.red : Colors.green;
    final badgeColor = isImportant ? Colors.red : Colors.green;
    final badgeLabel = isImportant ? 'Penting' : 'Biasa';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: arrowColor.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Checklist ────────────────────────────────────────────────
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: isDone ? Colors.green : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // ── Konten ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Deskripsi
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDone ? Colors.grey.shade400 : Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Badge kategori + tanggal
                  Row(
                    children: [
                      // Badge kategori
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: badgeColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isImportant
                                  ? Icons.star_rounded
                                  : Icons.task_alt_rounded,
                              size: 11,
                              color: badgeColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              badgeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: badgeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tanggal jatuh tempo
                      const Icon(Icons.calendar_today,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        task.dueDate,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Tombol Hapus + Panah ─────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hapus
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),

                // Panah — lebih besar dan jelas
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: arrowColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: arrowColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
