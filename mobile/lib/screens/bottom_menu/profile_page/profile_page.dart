import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/controllers/auth_controllers.dart';
import 'package:mobile/providers/profile_provider/profile_provider.dart';
import 'package:mobile/screens/home_screen/register/log_in_page.dart';

import 'change_password_page.dart';
import 'edit_profile.dart';
import 'package:mobile/models/profile_info/profile_model.dart';

/// Bottom nav'dagi "Profil" tab'i (IndexedStack ichida doimiy turadi).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(authControllerProvider.notifier).logout();
    if(!context.mounted) return;
    if(error != null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    // (token'larni flutter_secure_storage'dan o'chirish + login sahifaga o'tish)
    ref.invalidate(profileProvider); // keyingi akkaunt eski profilni ko'rmasligi uchun
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_)=> LogInPage()), 
      (_) => false);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Akkauntni o'chirish"),
        content: const Text(
          "Akkauntingiz faolsizlantiriladi va tizimga kira olmaysiz. Davom etasizmi?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final error = await ref.read(profileControllerProvider.notifier).deleteAccount();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      await _logout(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Profilni yuklab bo'lmadi"),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
        data: (p) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(profileProvider);
            try {
              await ref.read(profileProvider.future);
            } catch (_) {}
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _Header(profile: p),
              const SizedBox(height: 24),
              _MenuTile(
                icon: Icons.edit_outlined,
                title: 'Profilni tahrirlash',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfilePage(profile: p)),
                ),
              ),
              _MenuTile(
                icon: Icons.lock_outline,
                title: "Parolni o'zgartirish",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                ),
              ),
              const Divider(height: 32),
              _MenuTile(
                icon: Icons.logout,
                title: 'Chiqish',
                onTap: () => _logout(context, ref),
              ),
              _MenuTile(
                icon: Icons.delete_outline,
                title: "Akkauntni o'chirish",
                color: Theme.of(context).colorScheme.error,
                onTap: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = profile.displayName.isNotEmpty
        ? profile.displayName[0].toUpperCase()
        : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage:
              profile.avatar != null ? NetworkImage(profile.avatar!) : null,
          child: profile.avatar == null
              ? Text(initial, style: theme.textTheme.headlineMedium)
              : null,
        ),
        const SizedBox(height: 12),
        Text(profile.displayName, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          profile.hasPhone ? profile.phoneNumber! : 'Telefon raqam kiritilmagan',
          style: theme.textTheme.bodyMedium,
        ),
        if (profile.cityName != null) ...[
          const SizedBox(height: 2),
          Text(profile.cityName!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}