import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task_model.dart';
import 'detail_task_page.dart';

// ── Helper: parsing argument dari Navigator ────────────────────────────────
//
// Argument bisa berupa:
//   String          → category lama (backward-compatible)
//   Map<String,dynamic> → {category, isDone, addCategory}
//   null            → semua tugas

class _PageArgs {
  final String? category; // filter kategori (null = semua)
  final int? isDone; // filter status (null = semua)
  final String? addCategory; // kategori default tombol tambah

  const _PageArgs({this.category, this.isDone, this.addCategory});

  factory _PageArgs.fromArgument(Object? arg) {
    if (arg == null) {
      return const _PageArgs();
    }
    // Backward-compatible: argument lama berupa String category
    if (arg is String) {
      return _PageArgs(category: arg, addCategory: arg);
    }
    if (arg is Map<String, dynamic>) {
      return _PageArgs(
        category: arg['category'] as String?,
        isDone: arg['isDone'] as int?,
        addCategory: arg['addCategory'] as String?,
      );
    }
    return const _PageArgs();
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  late _PageArgs _args;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _args = _PageArgs.fromArgument(
        ModalRoute.of(context)?.settings.arguments,
      );
      _initialized = true;
    }
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await DatabaseHelper.instance.getAllTasks(
      category: _args.category,
      isDone: _args.isDone,
    );
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
        const SnackBar(
          backgroundColor: Color(0xFFD32F2F),
          content: Text('Tugas telah dihapus!'),
        ),
      );
    }
  }

  // Judul halaman berdasarkan kombinasi filter
  String get _pageTitle {
    if (_args.isDone == 1) return 'Tugas Selesai';
    if (_args.isDone == 0) return 'Tugas Belum Selesai';
    if (_args.category == 'important') return 'Tugas Penting';
    if (_args.category == 'regular') return 'Tugas Biasa';
    return 'Semua Tugas';
  }

  String? get _addTaskArgument {
    if (_args.isDone != null) return null;
    return _args.category; // bisa null → pilihan muncul
  }

  // FAB hanya tampil di:
  // - Semua Tugas
  // - Tugas Penting
  // - Tugas Biasa
  //
  // Tidak tampil di:
  // - Tugas Belum Selesai
  // - Tugas Selesai
  bool get _showFab => _args.category == null && _args.isDone == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada tugas',
                        style: TextStyle(color: Colors.grey.shade400),
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
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  '/add-task',
                  arguments: _addTaskArgument,
                );
                _loadTasks();
              },
              backgroundColor: const Color(0xFF1565C0),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// ── Task Card ─────────────────────────────────────────────────────────────────

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
    final arrowColor = isImportant ? Colors.red : const Color(0xFF2E7D32);
    final badgeColor = isImportant ? Colors.red : const Color(0xFF2E7D32);
    final badgeLabel = isImportant ? 'Penting' : 'Biasa';

    return Card(
      color: isImportant ? const Color(0xFFFFF1F1) : const Color(0xFFF1FAF3),
      surfaceTintColor: Colors.transparent,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: arrowColor.withValues(alpha: 0.75),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checklist untuk ubah status selesai/belum
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

            // Konten task, bisa diklik untuk lihat detail
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailTaskPage(task: task),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.5),
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
                        const Icon(
                          Icons.calendar_today,
                          size: 11,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          task.dueDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        if (isDone && task.completedDate != null) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle_outline,
                            size: 11,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            task.completedDate!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Delete + panah detail
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailTaskPage(task: task),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: arrowColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: arrowColor,
                      size: 22,
                    ),
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
