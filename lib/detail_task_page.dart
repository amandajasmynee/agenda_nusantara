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
    const primaryColor = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        centerTitle: false,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // CATEGORY BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isImportant
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isImportant
                              ? Icons.flag_rounded
                              : Icons.task_alt_rounded,
                          size: 18,
                          color: isImportant
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isImportant ? 'Tugas Penting' : 'Tugas Biasa',
                          style: TextStyle(
                            color: isImportant
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // DEADLINE
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: isImportant
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF2E7D32),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.dueDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // DESKRIPSI TITLE
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // DESKRIPSI BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      task.description.isEmpty
                          ? 'Tidak ada deskripsi'
                          : task.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: task.isDone == 1
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(14),
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
                        const SizedBox(width: 10),
                        Text(
                          task.isDone == 1 ? 'Sudah Selesai' : 'Belum Selesai',
                          style: TextStyle(
                            color: task.isDone == 1
                                ? const Color(0xFF2E7D32)
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
