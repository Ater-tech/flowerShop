import 'package:flutter/material.dart';

class DescriptionSection extends StatefulWidget {
  const DescriptionSection({super.key, required this.description});
  final String description;

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;
  bool _hasOverflow = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tavsif', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // Matn 4 qatorga sig'ib-sig'masligini oldindan hisoblaymiz
            final span = TextSpan(text: widget.description, style: textStyle);
            final painter = TextPainter(
              text: span,
              maxLines: 4,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);

            _hasOverflow = painter.didExceedMaxLines;

            return AnimatedCrossFade(
              firstChild: Text(
                widget.description,
                style: textStyle,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(widget.description, style: textStyle),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            );
          },
        ),
        if (_hasOverflow)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(_expanded ? 'Yopish' : 'Ko\'proq o\'qish'),
          ),
      ],
    );
  }
}
