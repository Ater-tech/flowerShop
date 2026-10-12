import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/error_handler/orders_deps.dart';
import 'package:mobile/server/api_endpoints.dart';



/// Backend: PATCH /api/shops/<id>/  (ShopViewSet manzilini o'zingizniki bilan almashtiring)
class ShopHandoverRepository {
  ShopHandoverRepository(this._dio);
  final Dio _dio;

  Future<Result<bool>> save(
    int shopId, {
    required bool delivery,
    required bool pickup,
    required bool taxi,
  }) =>
      guardRequest(() async {
        await _dio.patch('${ApiEndpoints.shops}$shopId/', data: {
          'allows_delivery': delivery,
          'allows_pickup': pickup,
          'allows_taxi': taxi,
        });
        return true;
      });
}

final shopHandoverRepositoryProvider = Provider<ShopHandoverRepository>(
  (ref) => ShopHandoverRepository(ref.watch(apiProvider).dio),
);

/// Sotuvchi do'kon sozlamalarida: xaridorlarga qaysi topshirish usullari ochiq.
/// "Kelishilgan joyda uchrashuv" doim mumkin (sotuvchi qabul qilish bilan hal qiladi).
class HandoverSettingsCard extends ConsumerStatefulWidget {
  const HandoverSettingsCard({
    super.key,
    required this.shopId,
    required this.initialDelivery,
    required this.initialPickup,
    required this.initialTaxi,
    this.onSaved,
  });

  final int shopId;
  final bool initialDelivery;
  final bool initialPickup;
  final bool initialTaxi;

  /// Saqlangandan keyin do'kon provider'laringizni yangilash uchun.
  final VoidCallback? onSaved;

  @override
  ConsumerState<HandoverSettingsCard> createState() => _HandoverSettingsCardState();
}

class _HandoverSettingsCardState extends ConsumerState<HandoverSettingsCard> {
  late bool _delivery = widget.initialDelivery;
  late bool _pickup = widget.initialPickup;
  late bool _taxi = widget.initialTaxi;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await ref.read(shopHandoverRepositoryProvider).save(
          widget.shopId,
          delivery: _delivery,
          pickup: _pickup,
          taxi: _taxi,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    final text = switch (result) {
      Success() => 'Saqlandi',
      Error(:final failure) => failureMessage(failure),
    };
    if (result is Success<bool>) widget.onSaved?.call();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Topshirish usullari', style: Theme.of(context).textTheme.titleMedium),
              SwitchListTile(
                value: _pickup,
                onChanged: (v) => setState(() => _pickup = v),
                title: const Text('Borib olish mumkin'),
              ),
              SwitchListTile(
                value: _delivery,
                onChanged: (v) => setState(() => _delivery = v),
                title: const Text("O'zim yetkazib beraman"),
              ),
              SwitchListTile(
                value: _taxi,
                onChanged: (v) => setState(() => _taxi = v),
                title: const Text('Taxi haydovchisiga berib yuborishga roziman'),
                subtitle: const Text("Taxi haqini xaridor to'laydi"),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Saqlash'),
                ),
              ),
            ],
          ),
        ),
      );
}
