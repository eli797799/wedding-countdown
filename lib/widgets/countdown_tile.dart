import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// אריח בודד בספירה לאחור (לדוגמה: "12" / "ימים").
/// הגודל נקבע יחסית למסך דרך [width] כדי להתאים גם למסכים קטנים מאוד.
class CountdownTile extends StatelessWidget {
  final String value;
  final String label;
  final double width;

  const CountdownTile({
    super.key,
    required this.value,
    required this.label,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.14;
    final radius = width * 0.26;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: width * 0.2,
                offset: Offset(0, width * 0.1),
              ),
            ],
          ),
          // FittedBox מבטיח שמספרים גדולים (כמו 312) לא יחרגו מהאריח.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.48,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        SizedBox(height: width * 0.11),
        Text(
          label,
          style: TextStyle(
            color: AppPalette.blush,
            fontSize: width * 0.19,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
