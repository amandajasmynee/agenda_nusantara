import 'package:flutter/material.dart';
import 'database_helper.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final username =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'user';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // ── Header Profil Kecil ────────────────────────────────────────
          _ProfileHeader(username: username),

          const SizedBox(height: 20),

          // ── Section: Akun ──────────────────────────────────────────────
          _SectionLabel(label: 'AKUN'),
          const SizedBox(height: 6),
          _MenuGroup(
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                iconColor: const Color(0xFFCC0000),
                title: 'Ganti Password',
                onTap: () => _showChangePasswordDialog(context, username),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                title: 'Tentang Aplikasi',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Agenda Nusantara',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text('Aplikasi manajemen agenda dan tugas harian.'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Section: Sesi ──────────────────────────────────────────────
          _SectionLabel(label: 'SESI'),
          const SizedBox(height: 6),
          _MenuGroup(
            children: [
              _SettingsTile(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Keluar',
                titleColor: Colors.red,
                showArrow: false,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Dialog Ganti Password ──────────────────────────────────────────────────

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
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
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
                              backgroundColor: ok ? Colors.green : Colors.red,
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

  // ── Dialog Konfirmasi Logout ───────────────────────────────────────────────

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
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Header Profil Kecil ───────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String username;

  const _ProfileHeader({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Icon user dalam lingkaran
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFCC0000).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFCC0000).withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: ClipOval(
            child: Image.asset(
              'assets/images/profile.jpg',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          ),
          const SizedBox(width: 14),

          // Teks info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${username[0].toUpperCase()}${username.substring(1)} 👋',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Agenda Nusantara',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Label Section ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Grup Menu (kartu putih) ───────────────────────────────────────────────────

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;

  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Tile Pengaturan ───────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final bool showArrow;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Divider tipis antar tile ──────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      endIndent: 0,
      color: Colors.grey.shade100,
    );
  }
}
