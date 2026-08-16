import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/models/shop_model.dart';
import 'package:mobile/providers/repo_providers.dart';
import 'package:mobile/repository/shop_repository.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ref.watch(apiProvider).shopRepositoryImpl;
});

final sellerShopsProvider = FutureProvider.autoDispose<List<ShopModel>>((ref) async {
  final result = await ref.watch(shopRepositoryProvider).getMyShops();
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

class ShopFormState {
  final ShopType shopType;
  final String name;
  final String address;
  final int? cityId;
  final double? latitude;
  final double? longitude;
  final bool isSubmitting;

  const ShopFormState({
    this.shopType = ShopType.personal,
    this.name = '',
    this.address = '',
    this.cityId,
    this.latitude,
    this.longitude,
    this.isSubmitting = false,
  });

  ShopFormState copyWith({
    ShopType? shopType,
    String? name,
    String? address,
    int? cityId,
    double? latitude,
    double? longitude,
    bool? isSubmitting,
  }) {
    return ShopFormState(
      shopType: shopType ?? this.shopType,
      name: name ?? this.name,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ShopFormController extends Notifier<ShopFormState> {
  @override
  ShopFormState build() => const ShopFormState();

  void setShopType(ShopType type) => state = state.copyWith(shopType: type);
  void setName(String value) => state = state.copyWith(name: value);
  void setAddress(String value) => state = state.copyWith(address: value);
  void setCity(int id) => state = state.copyWith(cityId: id);
  void setLocation(double lat, double lng) =>
      state = state.copyWith(latitude: lat, longitude: lng);

  Future<Result<ShopModel>> submit() async {
    state = state.copyWith(isSubmitting: true);

    final shop = ShopModel(
      shopType: state.shopType,
      name: state.name,
      address: state.address,
      cityId: state.cityId!,
      latitude: state.latitude!,
      longitude: state.longitude!,
    );

    final result = await ref.read(shopRepositoryProvider).createShop(shop);
    state = state.copyWith(isSubmitting: false);

    if (result is Success<ShopModel>) {
      ref.invalidate(sellerShopsProvider);
    }
    return result;
  }
}

final shopFormControllerProvider =
    NotifierProvider.autoDispose<ShopFormController, ShopFormState>(
  ShopFormController.new,
);