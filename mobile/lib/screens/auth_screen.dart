import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('E-posta ve şifre boş olamaz.');
      return;
    }

    if (password.length < 6) {
      showMessage('Şifre en az 6 karakter olmalı.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await authService.login(
          email: email,
          password: password,
        );
      } else {
        await authService.register(
          email: email,
          password: password,
        );
      }
    } catch (e) {
      showMessage(formatFirebaseError(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('Şifre sıfırlama için e-posta yazmalısın.');
      return;
    }

    try {
      await authService.sendPasswordResetEmail(email);
      showMessage('Şifre sıfırlama maili gönderildi.');
    } catch (e) {
      showMessage(formatFirebaseError(e.toString()));
    }
  }

  String formatFirebaseError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'Bu e-posta zaten kayıtlı.';
    }

    if (error.contains('user-not-found')) {
      return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
    }

    if (error.contains('wrong-password') || error.contains('invalid-credential')) {
      return 'E-posta veya şifre hatalı.';
    }

    if (error.contains('invalid-email')) {
      return 'Geçersiz e-posta adresi.';
    }

    if (error.contains('weak-password')) {
      return 'Şifre çok zayıf. En az 6 karakter kullan.';
    }

    return 'Bir hata oluştu. Lütfen tekrar dene.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/home_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.24),
                        Colors.black.withOpacity(0.64),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
                  children: [
                    Image.asset(
                      'assets/images/logo_alchemy.png',
                      height: 132,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1514).withOpacity(0.94),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFFFFD58A).withOpacity(0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD58A).withOpacity(0.20),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLogin ? 'Maceraya Giriş' : 'Yeni Hesap Oluştur',
                            style: const TextStyle(
                              color: Color(0xFFFFE7B2),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isLogin
                                ? 'Öğrenme dünyana devam et.'
                                : 'Kendi öğrenme krallığını başlat.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.62),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _AuthInput(
                            controller: emailController,
                            label: 'E-posta',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _AuthInput(
                            controller: passwordController,
                            label: 'Şifre',
                            icon: Icons.lock_rounded,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: Colors.white.withOpacity(0.55),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: resetPassword,
                                child: const Text(
                                  'Şifremi unuttum',
                                  style: TextStyle(
                                    color: Color(0xFFFFD58A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD58A),
                                foregroundColor: const Color(0xFF241309),
                                disabledBackgroundColor:
                                    const Color(0xFFFFD58A).withOpacity(0.45),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Color(0xFF241309),
                                      ),
                                    )
                                  : Text(
                                      isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        isLogin = !isLogin;
                                      });
                                    },
                              child: Text(
                                isLogin
                                    ? 'Hesabın yok mu? Kayıt ol'
                                    : 'Zaten hesabın var mı? Giriş yap',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
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
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _AuthInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFFFD58A),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withOpacity(0.28),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: const Color(0xFFFFD58A).withOpacity(0.20),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: Color(0xFFFFD58A),
            width: 1.6,
          ),
        ),
      ),
    );
  }
}