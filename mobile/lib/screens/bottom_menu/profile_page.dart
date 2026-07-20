import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget{
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends ConsumerState<ConsumerStatefulWidget>{
  @override
  Widget build(BuildContext context) {
   return  Center(child: Text("Loading..."));
  }
}