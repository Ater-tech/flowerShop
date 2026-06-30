// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/auth/providers/auth_providers.dart';

// ElevatedButton logIn(BuildContext context, AsyncValue<String?> authState) {
//     return ElevatedButton(
//       onPressed: authState.isLoading
//           ? null
//           : () async {
//               await ref
//                   .read(authProvider.notifier)
//                   .login(email.text, password.text);
//             },
//       child: authState.isLoading
//           ? Center(child: CircularProgressIndicator.adaptive())
//           : SizedBox(
//               width: MediaQuery.sizeOf(context).width,
//               child: Text(
//                 "LOGIN",
//                 style: TextStyle(color: Colors.blue),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//     );
//   }