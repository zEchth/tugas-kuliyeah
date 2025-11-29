import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  final supabase = Supabase.instance.client;

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E), // Dark background
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO BULAT
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    size: 74,
                    color: Color(0xFF4DA3FF), // biru neon dikit
                  ),
                ),

                const SizedBox(height: 32),

                // JUDUL
                const Text(
                  "Task Tracking",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Kelola tugas kuliahmu dengan mudah",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // TOMBOL GOOGLE DARK MODE
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 6,
                      shadowColor: Colors.black.withValues(alpha: 0.4),
                    ),
                    onPressed: () async {
                      try {
                        await supabase.auth.signInWithOAuth(
                          OAuthProvider.google,
                          redirectTo: kIsWeb
                              ? 'http://localhost:8111/' 
                              : 'tasktracking://login-callback',
                          authScreenLaunchMode: kIsWeb
                              ? LaunchMode.platformDefault
                              : LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Login gagal: $e")),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/images/g-logo.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Text(
                            'Masuk dengan Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // FOOTER
                Text(
                  "Dengan masuk, kamu menyetujui syarat & ketentuan.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
