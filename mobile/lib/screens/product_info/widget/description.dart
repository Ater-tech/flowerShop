import 'package:flutter/material.dart';

class _DescriptionSection extends StatefulWidget {
  const _DescriptionSection({required this.description});
  final String description;

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tavsif', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: Text(
            widget.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(widget.description),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(_expanded ? 'Yopish' : 'Ko\'proq o\'qish'),
        ),
      ],
    );
  }
}