import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ChowkLogo extends StatelessWidget {
  final double size;
  final double spacing;
  final TextStyle? textStyle;
  final bool showMark;

  const ChowkLogo({
    super.key,
    this.size = 10,
    this.spacing = 6,
    this.textStyle,
    this.showMark = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle =
        textStyle ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppTheme.chowkBlack,
          letterSpacing: 0.3,
        );

    final logoHeight = (effectiveTextStyle?.fontSize ?? size) * 1.4;

    return SizedBox(
      height: logoHeight,
      child: Image.asset(
        'assets/images/chowk-final-logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'CHOWK.',
            style: effectiveTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
    );
  }
}
