import 'package:flutter/material.dart';

/// Enum for different ambient shadow colors
enum AmbientShadowColor {
  orange,
  blue,
  purple,
  teal,
  red,
  amber,
  indigo,
  cyan,
  rose,
  green,
}

/// Card widget with ambient colored shadow glow effect
/// Matches the Stitch design "Recommended for You" cards
class AmbientCard extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final AmbientShadowColor shadowColor;
  final VoidCallback? onTap;
  final double hoverScale;
  final double hoverTranslateY;

  const AmbientCard({
    super.key,
    required this.child,
    this.width = 280,
    this.height = 420,
    this.borderRadius,
    this.shadowColor = AmbientShadowColor.orange,
    this.onTap,
    this.hoverScale = 1.05,
    this.hoverTranslateY = -16,
  });

  @override
  State<AmbientCard> createState() => _AmbientCardState();
}

class _AmbientCardState extends State<AmbientCard> {
  bool _isHovered = false;

  BoxShadow _getBaseShadow() {
    final color = _getColorFromEnum(widget.shadowColor);
    return BoxShadow(
      color: color.withValues(alpha: 0.5),
      blurRadius: 100,
      spreadRadius: -10,
      offset: const Offset(0, 40),
    );
  }

  BoxShadow _getHoverShadow() {
    final color = _getColorFromEnum(widget.shadowColor);
    return BoxShadow(
      color: color.withValues(alpha: 0.8),
      blurRadius: 120,
      spreadRadius: -5,
      offset: const Offset(0, 50),
    );
  }

  Color _getColorFromEnum(AmbientShadowColor shadowColor) {
    switch (shadowColor) {
      case AmbientShadowColor.orange:
        return const Color(0xFFFF641E);
      case AmbientShadowColor.blue:
        return const Color(0xFF285AFF);
      case AmbientShadowColor.purple:
        return const Color(0xFFA028FF);
      case AmbientShadowColor.teal:
        return const Color(0xFF28FFB4);
      case AmbientShadowColor.red:
        return const Color(0xFFFF2828);
      case AmbientShadowColor.amber:
        return const Color(0xFFFFAA28);
      case AmbientShadowColor.indigo:
        return const Color(0xFF5A28FF);
      case AmbientShadowColor.cyan:
        return const Color(0xFF28D2FF);
      case AmbientShadowColor.rose:
        return const Color(0xFFFF288C);
      case AmbientShadowColor.green:
        return const Color(0xFF28FF5A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(_isHovered ? widget.hoverScale : 1.0)
            ..translate(
              0.0,
              _isHovered ? widget.hoverTranslateY : 0.0,
              0.0,
            ),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: [
              _isHovered ? _getHoverShadow() : _getBaseShadow(),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
