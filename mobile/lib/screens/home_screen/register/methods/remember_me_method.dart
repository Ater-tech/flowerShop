import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/remember_me_provider.dart';

class RememberMeMethod extends ConsumerWidget {
  final Color color;
  const RememberMeMethod({super.key, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rememberMe = ref.watch(rememberMeProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          checkColor: color,
          // activeColor: Colors.transparent,
          fillColor: WidgetStateProperty.all(Colors.transparent),
          value: rememberMe,
          side: WidgetStateBorderSide.resolveWith(
            (states) => BorderSide(color: color),
          ),
          onChanged: (value) {
            ref.read(rememberMeProvider.notifier).state = value ?? false;
          },
        ),
        Text("Remember Me", style: TextStyle(color: color)),
      ],
    );
  }
}
