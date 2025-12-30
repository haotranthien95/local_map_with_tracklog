import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:local_map_with_tracklog/features/map/models/marker.dart';
import 'package:local_map_with_tracklog/features/map/models/marker_style.dart';

/// Shows a modal bottom sheet that guides the user through icon, color, and name steps.
Future<MapMarker?> showAddMarkerBottomSheet({
  required BuildContext context,
  required LatLng position,
  required List<MarkerStyle> styles,
  required MarkerStyle defaultStyle,
  required Color defaultColor,
}) {
  return showModalBottomSheet<MapMarker>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _MarkerStepper(
          position: position,
          styles: styles,
          defaultStyle: defaultStyle,
          defaultColor: defaultColor,
        ),
      );
    },
  );
}

class _MarkerStepper extends StatefulWidget {
  final LatLng position;
  final List<MarkerStyle> styles;
  final MarkerStyle defaultStyle;
  final Color defaultColor;

  const _MarkerStepper({
    required this.position,
    required this.styles,
    required this.defaultStyle,
    required this.defaultColor,
  });

  @override
  State<_MarkerStepper> createState() => _MarkerStepperState();
}

class _MarkerStepperState extends State<_MarkerStepper> {
  int _step = 0;
  late MarkerStyle _selectedStyle;
  late Color _selectedColor;
  String _name = '';
  late final TextEditingController _nameController;

  final List<Color> _palette = const [
    Color(0xFFE53935),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFFF8A65),
  ];

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.defaultStyle;
    _selectedColor = widget.defaultColor;
    _nameController = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_titleForStep(), style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStepContent(),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_step > 0)
                  TextButton(
                    onPressed: () => setState(() => _step -= 1),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _primaryEnabled() ? _onPrimary : null,
                  child: Text(_primaryLabel()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _EntryStep(position: widget.position);
      case 1:
        return _IconStep(
          styles: widget.styles,
          selected: _selectedStyle,
          onChanged: (style) => setState(() => _selectedStyle = style),
        );
      case 2:
        return _ColorStep(
          palette: _palette,
          selected: _selectedColor,
          onChanged: (color) => setState(() => _selectedColor = color),
        );
      case 3:
      default:
        return _NameStep(
          controller: _nameController,
          onChanged: (value) => setState(() => _name = value),
        );
    }
  }

  String _titleForStep() {
    if (_step == 0) return 'Add marker?';
    if (_step == 1) return 'Choose icon';
    if (_step == 2) return 'Choose color';
    return 'Name marker';
  }

  String _primaryLabel() {
    if (_step == 0) return 'Add marker';
    if (_step < 3) return 'Next';
    return 'Create';
  }

  bool _primaryEnabled() {
    if (_step < 3) return true;
    return _name.trim().isNotEmpty;
  }

  void _onPrimary() {
    if (_step < 3) {
      setState(() => _step += 1);
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final marker = MapMarker(
      id: 'marker_$now',
      lat: widget.position.latitude,
      lng: widget.position.longitude,
      name: _name.trim(),
      iconKey: _selectedStyle.key,
      colorHex: _toHex(_selectedColor),
      createdAt: now,
      updatedAt: now,
    );
    Navigator.of(context).pop(marker);
  }

  String _toHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

class _EntryStep extends StatelessWidget {
  final LatLng position;

  const _EntryStep({
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a marker at this location?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        const Text('You can choose an icon, a color, and a name in the next steps.'),
      ],
    );
  }
}

class _IconStep extends StatelessWidget {
  final List<MarkerStyle> styles;
  final MarkerStyle selected;
  final ValueChanged<MarkerStyle> onChanged;

  const _IconStep({
    required this.styles,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: styles.map((style) {
        final isSelected = style.key == selected.key;
        return InkWell(
          onTap: () => onChanged(style),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, size: 32),
                const SizedBox(height: 8),
                Text(style.label),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorStep extends StatelessWidget {
  final List<Color> palette;
  final Color selected;
  final ValueChanged<Color> onChanged;

  const _ColorStep({
    required this.palette,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: palette.map((color) {
        final isSelected = color.value == selected.value;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.white,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NameStep({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      decoration: const InputDecoration(
        labelText: 'Marker name',
        hintText: 'Enter a name',
      ),
      controller: controller,
      onChanged: onChanged,
    );
  }
}
