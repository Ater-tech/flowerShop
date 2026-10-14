import 'package:flutter/material.dart';


const _methods = {
  'pickup': 'Borib olish',
  'taxi': 'Taxi orqali',
  'seller_delivery': 'Sotuvchi yetkazadi',
  'meetup': 'Kelishilgan joyda',
};

Future<List<Map<String, dynamic>>?> showFulfillmentSheet(
  BuildContext context,
  List<int> shopIds,
) {
  return showModalBottomSheet<List<Map<String, dynamic>>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FulfillmentSheet(shopIds: shopIds),
  );
}

class FulfillmentSheet extends StatefulWidget {
  const FulfillmentSheet({super.key, required this.shopIds});
  final List<int> shopIds;
  @override
  State<FulfillmentSheet> createState() => _FulfillmentSheetState();
}

class _FulfillmentSheetState extends State<FulfillmentSheet> {
  late final Map<int, String> _method = {
    for (final id in widget.shopIds) id: 'pickup',
  };
  late final Map<int, TextEditingController> _notes = {
    for (final id in widget.shopIds) id: TextEditingController(),
  };
  String? _error;

  @override
  void dispose() {
    for (final c in _notes.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    for (final id in widget.shopIds) {
      if (_method[id] == 'meetup' && _notes[id]!.text.trim().isEmpty) {
        setState(() => _error = 'Uchrashuv joyini yozing');
        return;
      }
    }
    Navigator.of(context).pop([
      for (final id in widget.shopIds)
        {
          'shop': id,
          'fulfillment_method': _method[id],
          'meetup_note': _notes[id]!.text.trim(),
          'desired_at': null,
        },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final id in widget.shopIds) ...[
              Text("Do'kon #$id",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                isExpanded: true,
                value: _method[id],
                items: [
                  for (final e in _methods.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setState(() => _method[id] = v!),
              ),
              if (_method[id] == 'meetup')
                TextField(
                  controller: _notes[id],
                  decoration:
                      const InputDecoration(labelText: 'Uchrashuv joyi'),
                ),
              const SizedBox(height: 12),
            ],
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Tasdiqlash'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}