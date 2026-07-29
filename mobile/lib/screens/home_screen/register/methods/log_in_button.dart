import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/controllers/auth_controllers.dart';
import 'package:mobile/auth/providers/remember_me_provider.dart';

class LogInButton extends ConsumerWidget {
  final AsyncValue<void> authState;
  final TextEditingController email;
  final TextEditingController password;
  const LogInButton({
    super.key,
    required this.authState,
    required this.email,
    required this.password,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: authState.isLoading
          ? null
          : () async {
              final rememberMe = ref.read(rememberMeProvider);
              await ref
                  .read(authControllerProvider.notifier)
                  .login(email.text, password.text, rememberMe);
            },
      child: authState.isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Text(
                "LOGIN",
                style: TextStyle(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
  