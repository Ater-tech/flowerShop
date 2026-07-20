import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesPage extends ConsumerStatefulWidget{
  const MessagesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MessageState();
  }
}

class _MessageState extends ConsumerState<ConsumerStatefulWidget>{
  @override
  Widget build(BuildContext context) {
   return  Center(child: Text("Loading..."));
  }
}