import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Original SUP2I FOOD mascot illustration.
///
/// The character is a generic cheerful Italian-inspired chef designed for the
/// SUP2I FOOD product language: large friendly chef, moustache, white toque,
/// pink scarf and navy apron. It does not reproduce a third-party character.
class BrandChefMascot extends StatelessWidget {
  const BrandChefMascot({super.key, this.width = 132, this.height = 154});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Mascotte chef SUP2I FOOD',
      child: SizedBox(
        width: width,
        height: height,
        child: const CustomPaint(painter: _BrandChefPainter()),
      ),
    );
  }
}

class _BrandChefPainter extends CustomPainter {
  const _BrandChefPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final skin = Paint()..color = const Color(0xFFF1B38E);
    final white = Paint()..color = AppColors.neutral0;
    final navy = Paint()..color = AppColors.navy900;
    final pink = Paint()..color = AppColors.pink600;
    final dark = Paint()..color = const Color(0xFF3A241D);

    final cx = size.width * 0.50;
    final cy = size.height * 0.44;

    canvas.drawCircle(Offset(cx - 24, cy - 53), 28, white);
    canvas.drawCircle(Offset(cx + 5, cy - 61), 34, white);
    canvas.drawCircle(Offset(cx + 36, cy - 51), 27, white);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 5, cy - 31), width: 80, height: 38),
        const Radius.circular(17),
      ),
      white,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 2, cy), width: 90, height: 100),
      skin,
    );

    canvas.drawCircle(Offset(cx - 17, cy - 8), 3.6, dark);
    canvas.drawCircle(Offset(cx + 21, cy - 8), 3.6, dark);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 9, cy + 13), width: 31, height: 12),
      dark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 18, cy + 13), width: 31, height: 12),
      dark,
    );

    final smile = Paint()
      ..color = const Color(0xFF8C2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + 4, cy + 23), width: 36, height: 21),
      0.18,
      2.7,
      false,
      smile,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 3, cy + 83), width: 112, height: 100),
      white,
    );

    final scarf = Path()
      ..moveTo(cx - 38, cy + 48)
      ..lineTo(cx + 45, cy + 48)
      ..lineTo(cx + 23, cy + 72)
      ..lineTo(cx - 14, cy + 69)
      ..close();
    canvas.drawPath(scarf, pink);

    final apron = Path()
      ..moveTo(cx - 32, cy + 69)
      ..lineTo(cx + 40, cy + 69)
      ..lineTo(cx + 49, size.height)
      ..lineTo(cx - 44, size.height)
      ..close();
    canvas.drawPath(apron, navy);

    canvas.drawCircle(Offset(cx + 4, cy + 101), 12, pink);

    final sleeve = Paint()
      ..color = white.color
      ..strokeWidth = 23
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx + 42, cy + 69),
      Offset(size.width * 0.82, size.height * 0.55),
      sleeve,
    );

    final gesture = Paint()
      ..color = skin.color
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round;

    final hx = size.width * 0.84;
    final hy = size.height * 0.52;
    canvas.drawCircle(Offset(hx, hy), 17, skin);
    canvas.drawLine(Offset(hx, hy - 3), Offset(hx + 6, hy - 25), gesture);
    canvas.drawLine(Offset(hx + 2, hy), Offset(hx + 18, hy - 18), gesture);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
