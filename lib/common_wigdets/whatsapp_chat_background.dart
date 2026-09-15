import 'package:flutter/material.dart';

/// WhatsApp Dark Chat Background with subtle pattern and authentic colors
class WhatsAppChatBackground extends StatelessWidget {
  final Widget child;

  const WhatsAppChatBackground({
    super.key,
    required this.child,
  });

  static const Color darkBgColor = Color(0xFF0B141B);
  static const Color appBarColor = Color(0xFF1F2C34);
  static const Color myBubbleColor = Color(0xFF005C4B);
  static const Color otherBubbleColor = Color(0xFF202C33);
  static const Color datePillColor = Color(0xFF182229);
  static const Color textPrimary = Color(0xFFE9EDEF);
  static const Color textSecondary = Color(0xFF8696A0);
  static const Color checkmarkBlue = Color(0xFF53BDEB);
  static const Color sendButtonGreen = Color(0xFF00A884);
  static const Color inputBgColor = Color(0xFF202C33);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkBgColor,
      child: CustomPaint(
        painter: _WhatsAppPatternPainter(),
        child: child,
      ),
    );
  }
}

class _WhatsAppPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Subtle doodle/grid accent dots for WhatsApp dark wallpaper texture
    final paint = Paint()
      ..color = const Color(0xFF182229).withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 40.0;
    for (double x = 20; x < size.width; x += step) {
      for (double y = 20; y < size.height; y += step) {
        // Draw small subtle accent cross/dot
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
