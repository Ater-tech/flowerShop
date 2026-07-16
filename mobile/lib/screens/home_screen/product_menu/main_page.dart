import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/auth/providers/product_providers.dart';
import 'package:mobile/screens/home_screen/product_menu/widget/on_refresh.dart';
import 'widget/location_now.dart';
import 'widget/home_search_field.dart';
import 'widget/wallet_balance_card.dart';
import 'widget/promo_banner_carousel.dart';
import 'widget/occasion_category_row.dart';
import 'widget/products_list_ui.dart';
import 'widget/bottom_navigator_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          bottom: false,
          child: ProductRefreshIndicator(
            onRefresh: () { return onRefresh(ref);},
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: DeliveryLocationHeader()),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: HomeSearchField(
                    onTap: () {
                      // qidiruv sahifasiga o'tish
                    },
                    onFavoriteTap: () {
                      // sevimlilar sahifasiga o'tish
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: WalletBalanceCard(
                    onTap: () {
                      // hamyon/karta sahifasiga o'tish
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(child: PromoBannerCarousel()),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: OccasionCategoryRow(
                    onCategoryTap: (categoryId) {
                      // kategoriya bo'yicha filterlangan sahifaga o'tish
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const ProductGridList(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const HomeBottomNavBar(),
      ),
    );
  }

  Future<void> onRefresh(WidgetRef ref) async {
    final completer = Completer<void>();
  SchedulerBinding.instance.addPostFrameCallback((_) async {
    ref.invalidate(productControllerProvider);
    await ref.read(productControllerProvider.future);
    completer.complete();
  });
  return completer.future;
    // agar boshqa bloklar ham yangilanishi kerak bo'lsa:
    // ref.invalidate(bannerListProvider);
    // ref.invalidate(occasionCategoryListProvider);    
  }
}
