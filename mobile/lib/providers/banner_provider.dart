import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/product_models/banner_model.dart';
import 'package:mobile/repository/banner_repository.dart';
// eslatma: quyidagi importni sizning apiMainServiceProvider joylashgan
// fayl manziliga moslang (masalan: providers/repository_providers.dart)
import 'package:mobile/providers/repo_providers.dart';

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  final apiService = ref.watch(apiProvider);
  return BannerRepository(apiService.dio);
});

final bannerListProvider = FutureProvider<List<BannerModel>>((ref) async {
  final repo = ref.watch(bannerRepositoryProvider);
  return repo.fetchBanners();
});
