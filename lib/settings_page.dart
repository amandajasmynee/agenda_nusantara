import 'package:flutter/material.dart';
import 'database_helper.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final username =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Ganti Password
          ListTile(
            leading:
                const Icon(Icons.lock_outline, color: Color(0xFFCC0000)),
            title: const Text('Ganti Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context, username),
          ),
          const Divider(),

          // Tentang Aplikasi
          ListTile(
            leading:
                const Icon(Icons.info_outline, color: Color(0xFFCC0000)),
            title: const Text('Tentang Aplikasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Agenda Nusantara',
              applicationVersion: '1.0.0',
              children: const [
                Text('Aplikasi manajemen agenda dan tugas harian.'),
              ],
            ),
          ),
          const Divider(),

          // Keluar
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar',
                style: TextStyle(color: Colors.red)),
            onTap: () => _confirmLogout(context),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, String username) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ganti Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: oldPassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password Lama',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password Baru',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (v.length < 4) return 'Minimal 4 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (v != newPassCtrl.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isSaving = true);

                          final ok =
                              await DatabaseHelper.instance.changePassword(
                            username,
                            oldPassCtrl.text.trim(),
                            newPassCtrl.text.trim(),
                          );

                          if (!dialogContext.mounted) return;
                          setDialogState(() => isSaving = false);

                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? 'Password berhasil diubah!'
                                  : 'Password lama salah!'),
                              backgroundColor:
                                  ok ? Colors.green : Colors.red,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Keluar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}