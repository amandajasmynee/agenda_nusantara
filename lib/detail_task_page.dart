import 'package:flutter/material.dart';
import 'task_model.dart';

class DetailTaskPage extends StatelessWidget {
  final TaskModel task;

  const DetailTaskPage({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final isImportant = task.category == 'important';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FB),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    color: isImportant
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isImportant ? 'Tugas Penting' : 'Tugas Biasa',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isImportant
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded),
                  const SizedBox(width: 8),
                  Text(task.dueDate),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: task.isDone == 1
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      task.isDone == 1 ? Icons.check_circle : Icons.pending,
                      color: task.isDone == 1
                          ? const Color(0xFF2E7D32)
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.isDone == 1 ? 'Sudah Selesai' : 'Belum Selesai',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
