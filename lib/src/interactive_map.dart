import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';
import 'package:interactive_country_map/src/loaders.dart';
import 'package:interactive_country_map/src/painters/map_painter.dart';
import 'package:interactive_country_map/src/painters/marker_painter.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

/// Draw an interactive map from a SVG.
///
/// The SVG files must have `<path` with a field `id` otherwise the interactivity will not work
class InteractiveMap extends StatefulWidget {
  /// Use one of the predelivered map of the package
  InteractiveMap(
    MapEntity map, {
    super.key,
    this.onCountrySelected,
    this.onCountryHovered,
    this.theme = const InteractiveMapTheme(),
    this.loadingBuilder,
    this.minScale = 0.5,
    this.currentScale,
    this.maxScale = 8,
    this.selectedCode,
    this.hoveredCode,
    this.initialScale,
    this.markers = const [],
  }) : loader = MapEntityLoader(entity: map);

  // Load a map from an user's file
  InteractiveMap.file(
    File file, {
    super.key,
    this.onCountrySelected,
    this.onCountryHovered,
    this.theme = const InteractiveMapTheme(),
    this.loadingBuilder,
    this.minScale = 0.5,
    this.currentScale,
    this.maxScale = 8,
    this.selectedCode,    
    this.hoveredCode,
    this.initialScale,
    this.markers = const [],
  }) : loader = FileLoader(file: file);

  // Load a map from the assets of the app
  InteractiveMap.asset(
    String assetName, {
    super.key,
    this.onCountrySelected,
    this.onCountryHovered,
    this.theme = const InteractiveMapTheme(),
    this.loadingBuilder,
    this.minScale = 0.5,
    this.currentScale,
    this.maxScale = 8,
    this.selectedCode,
    this.hoveredCode,
    this.initialScale,
    this.markers = const [],
  }) : loader = AssetLoader(assetName: assetName);

  /// Used to load the SVG's string from somewhere(assets, files, others...)
  final SvgLoader loader;

  /// Called when a country/region is selected. Return the code as defined by the ISO 3166-2
  /// https://en.wikipedia.org/wiki/ISO_3166-2
  final void Function(String code)? onCountrySelected;

  /// Called when a country/region is hovered. Return the code as defined by the ISO 3166-2
  /// https://en.wikipedia.org/wiki/ISO_3166-2  
  final void Function(String code)? onCountryHovered;

  /// Draw layers of markers over the map
  final List<MarkerGroup> markers;

  // Theme
  final InteractiveMapTheme theme;

  /// Widget we display during the loading of the map
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Minimum value of a scale. Must be greater than 0
  final double minScale;

  /// Maximum scale value
  final double maxScale;

  /// Initial scale value
  final double? initialScale;

  /// Initial value for the zoom
  final double? currentScale;

  /// Code of the selected country/region
  final String? selectedCode;

  /// Code of the selected country/region
  final String? hoveredCode;

  @override
  State<InteractiveMap> createState() => InteractiveMapState();
}

class InteractiveMapState extends State<InteractiveMap> {
  String? svgData;
  late final TransformationController _controller;
  late double _scale;

  @override
  void initState() {
    super.initState();

    _scale = widget.initialScale ?? 1.0;
    final scaleMatrix = Matrix4.identity()..scale(_scale);
    _controller = TransformationController(scaleMatrix);

    Future.delayed(Duration.zero, loadMap);
  }

  @override
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.loader != widget.loader) {
      loadMap();
    }

    if (oldWidget.currentScale != widget.currentScale) {
      final scaleMatrix = Matrix4.identity()..scale(widget.currentScale ?? 1.0);
      _controller.value = scaleMatrix;
    }
  }

  /// Load the SVG's data
  Future<void> loadMap() async {
    final tmp = await widget.loader.load(context);

    setState(() {
      svgData = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (svgData != null) {
      return InteractiveViewer(
        transformationController: _controller,
        minScale: widget.minScale,
        maxScale: 200,
        panEnabled: true,
        onInteractionUpdate: (details) {
          setState(() {
            _scale = _controller.value[0];
          });
        },
        child: GeographicMap(
          svgData: svgData!,
          theme: widget.theme,
          onCountrySelected: widget.onCountrySelected,
          onCountryHovered: widget.onCountryHovered,
          hoveredCode: widget.hoveredCode,
          selectedCode: widget.selectedCode,
          markers: widget.markers,
          scale: _scale,
        ),
      );
    } else {
      return widget.loadingBuilder?.call(context) ?? const SizedBox.shrink();
    }
  }
}

class GeographicMap extends StatefulWidget {
  const GeographicMap({
    super.key,
    required this.svgData,
    required this.theme,
    this.onCountrySelected,
    this.onCountryHovered,
    this.selectedCode,
    this.hoveredCode,
    required this.markers,
    required this.scale,
  });

  final String svgData;
  final InteractiveMapTheme theme;
  final void Function(String code)? onCountrySelected;
  final void Function(String code)? onCountryHovered;
  final List<MarkerGroup> markers;
  final double scale;

  final String? selectedCode;
  final String? hoveredCode;

  @override
  State<GeographicMap> createState() => _GeographicMapState();
}

class _GeographicMapState extends State<GeographicMap> {
  CountryMap? countryMap;
  Offset? cursorPosition;
  Offset? hoverPosition;

  String? _selectedCode;
  String? _hoveredCode;

  // final _painterKey = GlobalKey<CustomPaint>();

  @override
  void initState() {
    super.initState();

    _selectedCode = widget.selectedCode;
    _hoveredCode = widget.hoveredCode;
    
    _parseSvg();
  }

  @override
  void didUpdateWidget(GeographicMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // only reparse the SVG when the svg data are differet
    if (oldWidget.svgData != widget.svgData) {
      _parseSvg();
    }
    if (oldWidget.selectedCode != widget.selectedCode) {
      setState(() {
        _selectedCode = widget.selectedCode;
      });
    }
  }

  Future<void> _parseSvg() async {
    final newPaths = await SvgParser().parse(widget.svgData);

    setState(() {
      countryMap = newPaths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(        
        onHover: (details) {
          setState(() {
            hoverPosition = details.localPosition;
          });
          // we crawl all the countries and just keep the first containing the cursor position
          final hoveredCountry = countryMap?.countryPaths
              .firstWhereOrNull((element) => element.path
                  .toPath(
                    maxSize: Size(constraints.maxWidth, constraints.maxHeight),
                    originalMapSize:
                        Size(countryMap!.width, countryMap!.height),
                  )
                  .contains(details.localPosition));

          if (hoveredCountry == null) {
            setState(() {
              _hoveredCode = null;
            });
          }
          else if (widget.onCountryHovered != null && _hoveredCode != hoveredCountry.countryCode) {
            widget.onCountryHovered!(hoveredCountry.countryCode);
            setState(() {
              _hoveredCode = hoveredCountry.countryCode;
            });
          }

        },
        child: GestureDetector(
        onTapUp: (details) {
          setState(() {
            // we need the cursor local position to detect if the cursor is inside a region or not
            cursorPosition = details.localPosition;
          });

          // we crawl all the countries and just keep the first containing the cursor position
          final selectedCountry = countryMap?.countryPaths
              .firstWhereOrNull((element) => element.path
                  .toPath(
                    maxSize: Size(constraints.maxWidth, constraints.maxHeight),
                    originalMapSize:
                        Size(countryMap!.width, countryMap!.height),
                  )
                  .contains(details.localPosition));

          if (selectedCountry != null && widget.onCountrySelected != null) {
            widget.onCountrySelected!(selectedCountry.countryCode);
            setState(() {
              _selectedCode = selectedCountry.countryCode;
            });
          }
        },
        child: Builder(
          builder: (context) {
            if (countryMap == null) {
              return const CircularProgressIndicator();
            }

            final countryMapAspectRatio =
                Size(countryMap!.width, countryMap!.height).aspectRatio;

            return AspectRatio(
              aspectRatio: countryMapAspectRatio,
              child: CustomPaint(
                painter: MapPainter(
                  countryMap: countryMap!,
                  cursorPosition: cursorPosition,
                  hoverPosition: hoverPosition,
                  theme: widget.theme,
                  selectedCode: _selectedCode,
                  hoveredCode: _hoveredCode,
                  canSelect: widget.onCountrySelected != null,
                  scale: widget.scale,
                ),
                foregroundPainter: MarkerPainter(
                  countryMap: countryMap!,
                  theme: widget.theme,
                  markers: widget.markers,
                  scale: widget.scale,
                ),
              ),
            );
          },
        ),
      ))
    );
  }
}
