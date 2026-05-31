import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  final UserProfileService profileService = UserProfileService();

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    profileService.ensureUserProfileExists();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2A211B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Future<void> logout() async {
    await authService.logout();
  }

  Future<void> sendResetPasswordMail() async {
    final email = user?.email;

    if (email == null) {
      showMessage('Kullanıcı e-postası bulunamadı.');
      return;
    }

    try {
      await authService.sendPasswordResetEmail(email);
      showMessage('Şifre sıfırlama maili gönderildi.');
    } catch (e) {
      showMessage('Mail gönderilemedi. Tekrar dene.');
    }
  }

  Future<void> changePasswordDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1514),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            'Şifre Değiştir',
            style: TextStyle(
              color: Color(0xFFFFE7B2),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Yeni şifre',
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.55),
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.25),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: const Color(0xFFFFD58A).withOpacity(0.22),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFFFFD58A),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Vazgeç',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD58A),
                foregroundColor: const Color(0xFF241309),
              ),
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    if (result.length < 6) {
      showMessage('Yeni şifre en az 6 karakter olmalı.');
      return;
    }

    try {
      await authService.updatePassword(result);
      showMessage('Şifre başarıyla güncellendi.');
    } catch (e) {
      showMessage(
        'Şifre değişikliği için yeniden giriş gerekebilir. Çıkış yapıp tekrar giriş yaptıktan sonra dene.',
      );
    }
  }

  Future<void> deleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1514),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            'Hesabı Sil',
            style: TextStyle(
              color: Color(0xFFFF6B8A),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Bu işlem hesabını siler. Emin misin?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Vazgeç',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3D6E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Hesabı Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await authService.deleteAccount();
      showMessage('Hesap silindi.');
    } catch (e) {
      showMessage(
        'Hesabı silmek için yeniden giriş gerekebilir. Çıkış yapıp tekrar giriş yaptıktan sonra dene.',
      );
    }
  }

  void openHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1514),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SizedBox(
          height: 520,
          child: StreamBuilder(
            stream: profileService.watchHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD58A),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Henüz tamamlanan macera yok.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  const Text(
                    'Geçmişim',
                    style: TextStyle(
                      color: Color(0xFFFFE7B2),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...docs.map((doc) {
                    final data = doc.data();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A211B),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFFFD58A).withOpacity(0.22),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['mapTitle'] ?? 'Macera',
                            style: const TextStyle(
                              color: Color(0xFFFFE7B2),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${data['field'] ?? ''} • ${data['topic'] ?? ''} • ${data['level'] ?? ''}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.64),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+${data['earnedGold'] ?? 0} altın',
                            style: const TextStyle(
                              color: Color(0xFF60D394),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: profileService.watchUserProfile(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final email = data['email'] ?? user?.email ?? 'Kullanıcı bulunamadı';
        final gold = data['gold'] ?? 0;
        final badges = data['badges'] ?? 0;
        final completedAdventures = data['completedAdventures'] ?? 0;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            Image.asset(
              'assets/images/logo_alchemy.png',
              height: 116,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            _ProfileHeroCard(email: email),
            const SizedBox(height: 16),
            _ProfileStatsCard(
              gold: gold,
              badges: badges,
              completedAdventures: completedAdventures,
            ),
          
            _ProfileActionTile(
              title: 'Şifre sıfırlama maili gönder',
              subtitle: 'Kayıtlı e-postana sıfırlama bağlantısı gönderilir',
              icon: Icons.mail_rounded,
              onTap: sendResetPasswordMail,
            ),
            _ProfileActionTile(
              title: 'Şifre değiştir',
              subtitle: 'Yeni şifre belirle',
              icon: Icons.lock_reset_rounded,
              onTap: changePasswordDialog,
            ),
            _ProfileActionTile(
              title: 'Geçmişim',
              subtitle: 'Tamamlanan maceraları görüntüle',
              icon: Icons.history_rounded,
              onTap: openHistorySheet,
            ),
            _ProfileActionTile(
              title: 'Çıkış yap',
              subtitle: 'Hesabından güvenli şekilde çık',
              icon: Icons.logout_rounded,
              onTap: logout,
            ),
            _ProfileActionTile(
              title: 'Hesabı sil',
              subtitle: 'Firebase hesabını kalıcı olarak sil',
              icon: Icons.delete_forever_rounded,
              danger: true,
              onTap: deleteAccountDialog,
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final String email;

  const _ProfileHeroCard({
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B2A1D).withOpacity(0.94),
            const Color(0xFF111827).withOpacity(0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.34),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD58A).withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD58A).withOpacity(0.18),
              border: Border.all(
                color: const Color(0xFFFFD58A).withOpacity(0.58),
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFFFFE7B2),
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oyuncu Profili',
                  style: TextStyle(
                    color: Color(0xFFFFE7B2),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 12.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsCard extends StatelessWidget {
  final int gold;
  final int badges;
  final int completedAdventures;

  const _ProfileStatsCard({
    required this.gold,
    required this.badges,
    required this.completedAdventures,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211B).withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ProfileStat(label: 'Altın', value: '$gold'),
          ),
          Expanded(
            child: _ProfileStat(label: 'Rozet', value: '$badges'),
          ),
          Expanded(
            child: _ProfileStat(label: 'Macera', value: '$completedAdventures'),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFE7B2),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.60),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  const _ProfileActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211B).withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: danger
              ? const Color(0xFFFF3D6E).withOpacity(0.36)
              : const Color(0xFFFFD58A).withOpacity(0.18),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: danger
                ? const Color(0xFFFF3D6E).withOpacity(0.16)
                : const Color(0xFFFFD58A).withOpacity(0.16),
          ),
          child: Icon(
            icon,
            color: danger ? const Color(0xFFFF6B8A) : const Color(0xFFFFE7B2),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: danger ? const Color(0xFFFF6B8A) : const Color(0xFFFFE7B2),
            fontSize: 13.7,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.52),
            fontSize: 11.2,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white.withOpacity(0.35),
          size: 15,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD58A).withOpacity(0.95),
            const Color(0xFF8A5A2D).withOpacity(0.95),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.settings_rounded,
            color: Color(0xFF2B170D),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2B170D),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF2B170D).withOpacity(0.72),
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}