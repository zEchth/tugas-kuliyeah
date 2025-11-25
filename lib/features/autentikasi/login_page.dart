import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  final supabase = Supabase.instance.client;

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await supabase.auth.signInWithOAuth(
              OAuthProvider.google,
              redirectTo: kIsWeb ? null : 'tasktracking://login-callback',
              authScreenLaunchMode:
                kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication, // Launch the auth screen in a new webview on mobile.
            );
          },
          child: const Text('Login dengan Google'),
        ),
      ),
    );
  }
}
