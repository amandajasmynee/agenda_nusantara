import 'package:flutter/material.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _doneTasks = 0;
  int _undoneTasks = 0;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);
    final done = await DatabaseHelper.instance.countDoneTasks();
    final undone = await DatabaseHelper.instance.countUndoneTasks();
    if (!mounted) return;
    setState(() {
      _doneTasks = done;
      _undoneTasks = undone;
      _isLoading = false;
    });
  }

  Future<void> _goToAddTask(String category) async {
    await Navigator.pushNamed(context, '/add-task', arguments: category);
    _loadCounts();
  }

  Future<void> _goToTaskList(String? category) async {
    await Navigator.pushNamed(context, '/task-list', arguments: category);
    _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    final username =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Nusantara'),
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings',
                  arguments: username);
              _loadCounts();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sambutan
              Text(
                'Halo, $username!',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Apa yang ingin Anda kelola hari ini?',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Statistik
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Belum Selesai',
                            count: _undoneTasks,
                            color: Colors.orange,
                            icon: Icons.pending_actions_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Selesai',
                            count: _doneTasks,
                            color: Colors.green,
                            icon: Icons.check_circle_rounded,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 28),

              // Tambah Tugas
              const Text(
                'Tambah Tugas',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.star_rounded,
                      label: 'Tambah Tugas\nPenting',
                      color: Colors.red,
                      onTap: () => _goToAddTask('important'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.task_alt_rounded,
                      label: 'Tambah Tugas\nBiasa',
                      color: Colors.blue,
                      onTap: () => _goToAddTask('regular'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Lihat Tugas
              const Text(
                'Lihat Tugas',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                icon: Icons.star_rounded,
                title: 'Tugas Penting',
                subtitle: 'Kelola tugas prioritas tinggi',
                color: Colors.red,
                onTap: () => _goToTaskList('important'),
              ),
              const SizedBox(height: 10),
              _MenuCard(
                icon: Icons.task_alt_rounded,
                title: 'Tugas Biasa',
                subtitle: 'Daftar aktivitas sehari-hari',
                color: Colors.blue,
                onTap: () => _goToTaskList('regular'),
              ),
              const SizedBox(height: 10),
              _MenuCard(
                icon: Icons.list_alt_rounded,
                title: 'Semua Tugas',
                subtitle: 'Lihat seluruh agenda Anda',
                color: Colors.teal,
                onTap: () => _goToTaskList(null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action Button (Tambah Tugas) ─────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Card (Lihat Tugas) ───────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}