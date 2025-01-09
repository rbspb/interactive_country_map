import 'package:flutter/material.dart';

/// Customize the InteractiveMap widget with this theme
class InteractiveMapTheme {
  // The default color to paint a country
  final Color defaultCountryColor;

  // The default color to paint a country when it's selected
  final Color defaultSelectedCountryColor;

  final Color defaultHoveredCountryColor;

  // We want to map the code of a country region to a special color
  // eg: FR -> Colors.red.shade200
  final Map<String, Color>? mappingCode;

  // The default opacity when not hovered or selected
  final double defaultOpacity;

  // The opacity when selected
  final double selectedOpacity;
  
  // The opacity when hovered
  final double hoveredOpacity;
  
  // The border width of the countries
  final double borderWidth;

  // The border width of the selected country
  final double selectedBorderWidth;

  // The border width of the hovered country
  final double hoveredBorderWidth;

  // The color of the country's border
  final Color borderColor;

  // The selected color of the country's border
  final Color selectedBorderColor;

  // The selected color of the country's border
  final Color hoveredBorderColor;

  // The color to fill the background of the map
  final Color? backgroundColor;

  const InteractiveMapTheme({
    this.defaultCountryColor = const Color(0xffdddddd),
    this.defaultSelectedCountryColor = const Color(0xffaaccaa),    
    this.defaultHoveredCountryColor = const Color(0xff5566aa),
    this.defaultOpacity = 0.5,
    this.hoveredOpacity = 0.8,
    this.selectedOpacity = 0.2,
    
    this.mappingCode,
    this.borderWidth = 0.1,
    this.selectedBorderWidth = 1,
    this.hoveredBorderWidth = 1.2,
    this.selectedBorderColor = Colors.white,
    this.hoveredBorderColor = Colors.black,
    this.borderColor = Colors.black,
    this.backgroundColor = Colors.white,
  });
}
