import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: InteractiveMap(
              
              onCountryHovered: (code) {
                print("$code hovered.");
              },
              onCountrySelected: (code) {              
                print("$code selected.");
              },
              MapEntity.world,

              theme: const InteractiveMapTheme(),
              initialScale: 1,
            ),
          ),
        ],
      ),
    );
  }
}
