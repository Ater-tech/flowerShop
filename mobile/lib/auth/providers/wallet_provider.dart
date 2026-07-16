import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Default holatda yashirin (false = hidden/masked)
final isBalanceVisibleProvider = StateProvider<bool>((ref) => false);

/// Backenddan olinadigan balans (hozircha statik, keyin FutureProvider bilan
/// almashtiriladi)
final walletBalanceProvider = Provider<double>((ref) => 800000.0);