import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task_model.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = 'regular';
  DateTime? _selectedDueDate;
  bool _isSaving = false;
  bool _initialized = false;

  // null  → dibuka dari Semua Tugas, tampilkan pilihan kategori
  // 'important' / 'regular' → kategori terkunci
  String? _argCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _argCategory =
          ModalRoute.of(context)?.settings.arguments as String?;
      if (_argCategory != null) {
        _category = _argCategory!;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _categoryLocked => _argCategory != null;

  String get _pageTitle {
    if (_argCategory == 'important') return 'Tambah Tugas Penting';
    if (_argCategory == 'regular') return 'Tambah Tugas Biasa';
    return 'Tambah Tugas';
  }

  Color get _themeColor =>
      _category == 'important' ? Colors.red : Colors.blue;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal jatuh tempo wajib dipilih'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final task = TaskModel(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: _formatDate(_selectedDueDate!),
      category: _category,
      isDone: 0,
    );

    await DatabaseHelper.instance.insertTask(task);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tugas berhasil ditambahkan!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Kategori: terkunci atau bisa dipilih ──────────────────────
              _categoryLocked
                  ? _LockedCategoryBadge(category: _category)
                  : _CategorySelector(
                      selected: _category,
                      onChanged: (val) => setState(() => _category = val),
                    ),
              const SizedBox(height: 20),

              // ── Judul Tugas ───────────────────────────────────────────────
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // ── Deskripsi ─────────────────────────────────────────────────
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // ── Tanggal Jatuh Tempo ───────────────────────────────────────
              const Text(
                'Tanggal Jatuh Tempo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedDueDate != null
                          ? _themeColor
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _selectedDueDate != null
                            ? _themeColor
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDueDate == null
                            ? 'Pilih tanggal...'
                            : _formatDate(_selectedDueDate!),
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedDueDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ── Tombol Simpan ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge kategori terkunci (argument tidak null) ────────────────────────────

class _LockedCategoryBadge extends StatelessWidget {
  final String category;

  const _LockedCategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final isImportant = category == 'important';
    final color = isImportant ? Colors.red : Colors.blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isImportant ? Icons.star_rounded : Icons.task_alt_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isImportant ? 'Kategori: Tugas Penting' : 'Kategori: Tugas Biasa',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(Icons.lock_outline, color: color, size: 16),
        ],
      ),
    );
  }
}

// ── Pilihan kategori bebas (argument null / dari Semua Tugas) ────────────────

class _CategorySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategorySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _CategoryChip(
              label: 'Tugas Biasa',
              icon: Icons.task_alt_rounded,
              selected: selected == 'regular',
              color: Colors.blue,
              onTap: () => onChanged('regular'),
            ),
            const SizedBox(width: 10),
            _CategoryChip(
              label: 'Tugas Penting',
              icon: Icons.star_rounded,
              selected: selected == 'important',
              color: Colors.red,
              onTap: () => onChanged('important'),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey.shade100,
          border: Border.all(
              color: selected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.grey,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}