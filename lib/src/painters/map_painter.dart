import 'dart:ui';

import 'package:flutter/material.dart' hide Path;
import 'package:interactive_country_map/src/interactive_map_theme.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class MapPainter extends CustomPainter {
  final CountryMap countryMap;
  final Offset? cursorPosition;
  final InteractiveMapTheme theme;
  final String? selectedCode;
  final bool canSelect;
  final double scale;

  MapPainter({
    super.repaint,
    required this.countryMap,
    required this.cursorPosition,
    required this.theme,
    required this.selectedCode,
    required this.canSelect,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFiller = Paint()
      ..color = theme.defaultCountryColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final selectedPaintFiller = Paint()
      ..color = theme.defaultSelectedCountryColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final paintBorder = Paint()
      ..color = theme.borderColor
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.borderWidth / scale;
    final selectedPaintBorder = Paint()
      ..color = theme.borderColor
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.selectedBorderWidth / scale;

    for (var country in countryMap.countryPaths) {
      final path = country.path.toPath(
        maxSize: size,
        originalMapSize: Size(countryMap.width, countryMap.height),
      );
      paintFiller.color =
          theme.mappingCode?[country.countryCode] ?? theme.defaultCountryColor;

      if (_canBeDrawnAsSelected(country.countryCode, path)) {
        canvas.drawPath(path, selectedPaintFiller);
        canvas.drawPath(path, selectedPaintBorder);
      } else {
        canvas.drawPath(path, paintFiller);
        canvas.drawPath(path, paintBorder);
      }
    }
  }

  bool _canBeDrawnAsSelected(String countryCode, Path path) {
    if (selectedCode != null) {
      return selectedCode == countryCode;
    } else if (canSelect &&
        cursorPosition != null &&
        path.contains(cursorPosition!)) {
      return true;
    }

    return false;
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.countryMap != countryMap ||
        oldDelegate.cursorPosition != cursorPosition ||
        oldDelegate.theme != theme ||
        oldDelegate.selectedCode != selectedCode ||
        oldDelegate.canSelect != canSelect;
  }
}
