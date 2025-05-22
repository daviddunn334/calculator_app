import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';
import '../models/pipeline_element.dart';
import '../models/pipeline_layout.dart';
import '../services/pipeline_layout_service.dart';

class PipelineSchematicScreen extends StatefulWidget {
  final PipelineLayout? initialLayout;

  const PipelineSchematicScreen({
    super.key,
    this.initialLayout,
  });

  @override
  State<PipelineSchematicScreen> createState() => _PipelineSchematicScreenState();
}

class _PipelineSchematicScreenState extends State<PipelineSchematicScreen> {
  final _layoutService = PipelineLayoutService();
  final _uuid = const Uuid();
  late PipelineLayout _layout;
  PipelineElement? _selectedElement;
  Offset? _dragStartPosition;
  final _gridSize = 20.0;

  @override
  void initState() {
    super.initState();
    _layout = widget.initialLayout ??
        PipelineLayout(
          id: '',
          name: 'New Layout',
        );
  }

  void _addElement(PipelineElementType type, Offset position) {
    setState(() {
      _layout = _layout.copyWith(
        elements: [
          ..._layout.elements,
          PipelineElement(
            id: _uuid.v4(),
            type: type,
            position: position,
          ),
        ],
      );
    });
  }

  void _updateElementPosition(String id, Offset newPosition) {
    setState(() {
      _layout = _layout.copyWith(
        elements: _layout.elements.map((element) {
          if (element.id == id) {
            return element.copyWith(
              position: Offset(
                (newPosition.dx / _gridSize).round() * _gridSize,
                (newPosition.dy / _gridSize).round() * _gridSize,
              ),
            );
          }
          return element;
        }).toList(),
      );
    });
  }

  void _updateElementLabel(String id, String label) {
    setState(() {
      _layout = _layout.copyWith(
        elements: _layout.elements.map((element) {
          if (element.id == id) {
            return element.copyWith(label: label);
          }
          return element;
        }).toList(),
      );
    });
  }

  void _deleteElement(String id) {
    setState(() {
      _layout = _layout.copyWith(
        elements: _layout.elements.where((element) => element.id != id).toList(),
      );
    });
  }

  Future<void> _saveLayout() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Layout'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Layout Name',
          ),
          controller: TextEditingController(text: _layout.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final textField = context.findRenderObject()?.descendantRenderObjectOfType<RenderEditable>();
              Navigator.pop(context, textField?.text?.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await _layoutService.saveLayout(_layout.copyWith(name: name));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layout saved successfully')),
        );
      }
    }
  }

  Future<void> _exportAsImage() async {
    // TODO: Implement image export
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_layout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveLayout,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _exportAsImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Grid background
          CustomPaint(
            painter: GridPainter(gridSize: _gridSize),
            size: Size.infinite,
          ),
          // Pipeline elements
          GestureDetector(
            onPanStart: (details) {
              _dragStartPosition = details.localPosition;
            },
            onPanUpdate: (details) {
              if (_selectedElement != null) {
                _updateElementPosition(
                  _selectedElement!.id,
                  details.localPosition,
                );
              }
            },
            onPanEnd: (_) {
              _dragStartPosition = null;
            },
            child: CustomPaint(
              painter: PipelineElementsPainter(
                elements: _layout.elements,
                selectedElement: _selectedElement,
              ),
              size: Size.infinite,
            ),
          ),
          // Element palette
          Positioned(
            right: 16,
            top: 16,
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPaletteItem(
                    Icons.crop_square,
                    'Pipe',
                    PipelineElementType.pipe,
                  ),
                  _buildPaletteItem(
                    Icons.turn_right,
                    'Bend',
                    PipelineElementType.bend,
                  ),
                  _buildPaletteItem(
                    Icons.tap_and_play,
                    'Valve',
                    PipelineElementType.valve,
                  ),
                  _buildPaletteItem(
                    Icons.call_split,
                    'Tee',
                    PipelineElementType.tee,
                  ),
                  _buildPaletteItem(
                    Icons.circle,
                    'Weld',
                    PipelineElementType.weld,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaletteItem(
    IconData icon,
    String label,
    PipelineElementType type,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        _addElement(
          type,
          Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height / 2,
          ),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    for (var i = 0.0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (var i = 0.0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PipelineElementsPainter extends CustomPainter {
  final List<PipelineElement> elements;
  final PipelineElement? selectedElement;

  PipelineElementsPainter({
    required this.elements,
    this.selectedElement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      final paint = Paint()
        ..color = element.color
        ..strokeWidth = 2;

      if (element == selectedElement) {
        paint.color = Colors.red;
      }

      switch (element.type) {
        case PipelineElementType.pipe:
          canvas.drawRect(
            Rect.fromLTWH(
              element.position.dx - 20,
              element.position.dy - 10,
              40,
              20,
            ),
            paint,
          );
          break;
        case PipelineElementType.bend:
          canvas.drawArc(
            Rect.fromCircle(
              center: element.position,
              radius: 20,
            ),
            0,
            ui.pi / 2,
            false,
            paint,
          );
          break;
        case PipelineElementType.valve:
          canvas.drawCircle(element.position, 15, paint);
          break;
        case PipelineElementType.tee:
          canvas.drawPath(
            Path()
              ..moveTo(element.position.dx, element.position.dy - 20)
              ..lineTo(element.position.dx, element.position.dy + 20)
              ..moveTo(element.position.dx - 20, element.position.dy)
              ..lineTo(element.position.dx + 20, element.position.dy),
            paint,
          );
          break;
        case PipelineElementType.weld:
          canvas.drawCircle(element.position, 5, paint);
          break;
      }

      if (element.label.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            element.position.dx - textPainter.width / 2,
            element.position.dy - 30,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 