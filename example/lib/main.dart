import 'dart:async';

import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? selectedRegion;
  MapEntity map = MapEntity.france;
  double _currentScale = 0.8;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: InteractiveMap(
                  theme: InteractiveMapTheme(
                    borderColor: Colors.green.shade800,
                    borderWidth: 1.0,
                    selectedBorderWidth: 3.0,
                    defaultCountryColor: Colors.grey.shade300,
                    defaultSelectedCountryColor: Colors.green.shade200,
                    mappingCode: {
                      ...MappingHelper.sameColor(
                        Colors.green.shade300,
                        [
                          "FR-A",
                          "FR-B",
                          "FR-C",
                          "FR-D",
                          "FR-E",
                        ],
                      )
                    },
                  ),
                  loadingWidget: Container(
                    color: Colors.red,
                    width: 100,
                    height: 100,
                  ),
                  onCountrySelected: (code) {
                    setState(() {
                      selectedRegion = code;
                    });
                  },
                  map: map,
                  selectedCode: selectedRegion,
                  initialScale: 3.0,
                  currentScale: _currentScale,
                ),
              ),
              if (selectedRegion != null)
                Text(
                  "Selected area: $selectedRegion",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    if (_currentScale <= 8) {
                      _currentScale += 1;
                    }
                  });
                },
                child: Text("Zoom in"),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    if (_currentScale - 1 > 0) {
                      _currentScale -= 1;
                    }
                  });
                },
                child: Text("Zoom out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
