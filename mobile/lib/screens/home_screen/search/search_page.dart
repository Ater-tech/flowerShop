import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/product_provider/product_search_providers.dart';
import 'package:mobile/providers/search_providers.dart';
import 'package:mobile/screens/home_screen/search/widget/discover_section.dart';
import 'package:mobile/screens/home_screen/search/widget/search_bar.dart';
import 'package:mobile/screens/home_screen/search/widget/search_history_section.dart';
import 'package:mobile/screens/home_screen/search/widget/search_results_sliver.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchState();
}

class _SearchState extends ConsumerState<SearchPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(rawSearchInputProvider.notifier).state = '';
      }
    });
  }

  void _saveCurrentQuery() {
    final q = ref.read(rawSearchInputProvider).trim();
    if (q.length >= 2) {
      ref.read(searchHistoryControllerProvider.notifier).add(q);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(searchDebouncerProvider);
    final isTyping = ref.watch(rawSearchInputProvider).trim().isNotEmpty;
    return PopScope(
      canPop: !isTyping,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _saveCurrentQuery();
        ref.read(rawSearchInputProvider.notifier).state = '';
        FocusScope.of(context).unfocus();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SearchBarWidget()),
                if (isTyping)
                  const SearchResultsSliver()
                else ...[
                  SliverToBoxAdapter(
                    child: SearchHistorySection(
                      onSelected: (query) {
                        ref.read(rawSearchInputProvider.notifier).state = query;
                        ref
                            .read(searchHistoryControllerProvider.notifier)
                            .add(query);
                        FocusScope.of(context).unfocus();
                        debugPrint('history tapped: $query');
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: DiscoverSection()),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
