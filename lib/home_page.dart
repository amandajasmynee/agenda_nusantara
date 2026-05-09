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
  int _totalTasks = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _chartData = [];

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 11) {
      return 'Selamat pagi';
    } else if (hour < 15) {
      return 'Selamat siang';
    } else if (hour < 18) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }

  String _formattedDateTime() {
    final now = DateTime.now();

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '$dayName, ${now.day} $monthName ${now.year} • $hour:$minute';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);

    final done = await DatabaseHelper.instance.countDoneTasks();
    final undone = await DatabaseHelper.instance.countUndoneTasks();
    final chart = await DatabaseHelper.instance.getCompletedTasksPerDay();
    final total = done + undone;

    if (!mounted) return;

    setState(() {
      _doneTasks = done;
      _undoneTasks = undone;
      _totalTasks = total;
      _chartData = chart;
      _isLoading = false;
    });
  }

  // ⬇️ TAMBAH DI SINI
  Future<void> _openTaskList({
    String? category,
    int? isDone,
    String? addCategory,
  }) async {
    await Navigator.pushNamed(
      context,
      '/task-list',
      arguments: <String, dynamic>{
        'category': category,
        'isDone': isDone,
        'addCategory': addCategory,
      },
    );

    _loadCounts();
  }

  Future<void> _goToAddTask(String category) async {
    await Navigator.pushNamed(context, '/add-task', arguments: category);
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
              await Navigator.pushNamed(
                context,
                '/settings',
                arguments: username,
              );
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
              // Greeting
              Text(
                '${_greeting()}, ${username[0].toUpperCase()}${username.substring(1)} 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Apa yang ingin Anda kelola hari ini?',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 6),

              Text(
                _formattedDateTime(),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              // Statistik
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        _StatCard(
                          label: 'Semua Tugas',
                          count: _totalTasks,
                          color: Colors.teal,
                          icon: Icons.list_alt_rounded,
                          onTap: () => _openTaskList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Belum Selesai',
                                count: _undoneTasks,
                                color: Colors.orange,
                                icon: Icons.pending_actions_rounded,
                                onTap: () => _openTaskList(isDone: 0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Selesai',
                                count: _doneTasks,
                                color: Colors.green,
                                icon: Icons.check_circle_rounded,
                                onTap: () => _openTaskList(isDone: 1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

              // Grafik
              if (!_isLoading) ...[
                _ChartSection(chartData: _chartData),
                const SizedBox(height: 28),
              ],

              // Tambah Tugas
              const Text(
                'Tambah Tugas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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

              // Lihat tugas
              const Text(
                'Lihat Tugas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              _MenuCard(
                icon: Icons.star_rounded,
                title: 'Tugas Penting',
                subtitle: 'Kelola tugas prioritas tinggi',
                color: Colors.red,
                onTap: () => _openTaskList(category: 'important'),
              ),

              const SizedBox(height: 10),

              _MenuCard(
                icon: Icons.task_alt_rounded,
                title: 'Tugas Biasa',
                subtitle: 'Daftar aktivitas sehari-hari',
                color: Colors.blue,
                onTap: () => _openTaskList(category: 'regular'),
              ),

              const SizedBox(height: 10),

              _MenuCard(
                icon: Icons.list_alt_rounded,
                title: 'Semua Tugas',
                subtitle: 'Lihat seluruh agenda Anda',
                color: Colors.teal,
                onTap: () => _openTaskList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHART SECTION
// ─────────────────────────────────────────────────────────────

class _ChartSection extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const _ChartSection({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Belum ada tugas selesai',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final maxCount =
        chartData.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b);

    const double chartHeight = 90;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Tugas Selesai',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: chartHeight + 45,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((item) {
                final count = item['count'] as int;

                final ratio = maxCount > 0 ? count / maxCount : 0.0;

                final barHeight =
                    (chartHeight * ratio).clamp(12.0, chartHeight);

                final raw = item['date'] as String;
                final parts = raw.split('/');

                final label =
                    parts.length >= 2 ? '${parts[0]}/${parts[1]}' : raw;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
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
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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

// ─────────────────────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────────────────────

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
          border: Border.all(
            color: color.withOpacity(0.4),
          ),
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

// ─────────────────────────────────────────────────────────────
// MENU CARD
// ─────────────────────────────────────────────────────────────

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
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
