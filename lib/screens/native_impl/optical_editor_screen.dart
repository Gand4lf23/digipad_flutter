import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'optical_logic_controller.dart';
import 'optical_painter.dart';

class OpticalEditorScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> detections;
  final bool isFrontCamera;

  const OpticalEditorScreen({
    super.key,
    required this.imagePath,
    required this.detections,
    this.isFrontCamera = false,
  });

  @override
  State<OpticalEditorScreen> createState() => _OpticalEditorScreenState();
}

class _OpticalEditorScreenState extends State<OpticalEditorScreen> {
  late OpticalController _controller;
  late File _imageFile;
  Size? _imageSize;
  final TransformationController _transformationController =
      TransformationController();

  bool _isMoveMode = false;
  bool _showAjustePanel = false;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imagePath);
    _controller = OpticalController();
    _loadImageAndInit();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImageAndInit() async {
    try {
      final bytes = await _imageFile.readAsBytes();
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _imageSize = Size(
            frame.image.width.toDouble(),
            frame.image.height.toDouble(),
          );
          _controller.initialize(widget.detections, _imageSize!);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageSize == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Ajuste Medidas"),
          backgroundColor: const Color(0xFF1C1C1E),
          actions: [
            // Botón Compartir
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _showResultsSheet,
              tooltip: 'Compartir Resultados',
            ),

            // Botón Calibración
            IconButton(
              icon: Icon(
                Icons.tune,
                color: _showAjustePanel ? Colors.orangeAccent : Colors.white,
              ),
              onPressed: () =>
                  setState(() => _showAjustePanel = !_showAjustePanel),
              tooltip: 'Calibración',
            ),

            // Botón Move/Zoom
            IconButton(
              icon: Icon(
                _isMoveMode ? Icons.pan_tool : Icons.zoom_in,
                color: _isMoveMode ? Colors.greenAccent : Colors.white,
              ),
              onPressed: () => setState(() => _isMoveMode = !_isMoveMode),
              tooltip: _isMoveMode ? 'Modo Edición' : 'Modo Zoom',
            ),

            // Botón Confirmar
            Builder(
              builder: (context) {
                if (_isMoveMode || _controller.selectedPoint != null) {
                  return IconButton(
                    icon: const Icon(Icons.check, color: Colors.cyanAccent),
                    onPressed: () {
                      setState(() {
                        _isMoveMode = false;
                        _showAjustePanel = false;
                      });
                      _controller.selectedPoint = null;
                      _controller.notifyListeners();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // PANEL DE CONTROLES SUPERIOR
            _buildTopControls(),

            // PANEL DE CALIBRACION (expandible)
            if (_showAjustePanel) _buildCalibrationPanel(),

            // IMAGEN CON OVERLAY
            Expanded(
              flex: 3,
              child: Stack(
                children: [_buildImageViewer(), _buildNudgeControls()],
              ),
            ),

            // PANEL DE RESULTADOS INFERIOR
            Expanded(flex: 2, child: _buildInfoPanel()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Container(
      height: 50,
      color: Colors.grey[900],
      child: Consumer<OpticalController>(
        builder: (context, ctrl, _) => Row(
          children: [
            // Toggle Círculos
            Checkbox(
              value: ctrl.showCircles,
              activeColor: Colors.cyanAccent,
              onChanged: (v) => ctrl.toggleCircles(v!),
            ),
            if (!ctrl.showCircles)
              const Text(
                "Guías",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),

            // Slider Diámetro Referencia
            if (ctrl.showCircles) ...[
              Expanded(
                child: Slider(
                  value: ctrl.referenceCircleDiameter,
                  min: 40,
                  max: 90,
                  divisions: 50,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (v) => ctrl.setReferenceDiameter(v),
                ),
              ),
              Text(
                "Ref: ${ctrl.referenceCircleDiameter.round()}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
            ],

            const VerticalDivider(color: Colors.white24, width: 20),

            // Toggle Bifocal
            Switch(
              value: ctrl.isBifocal,
              activeColor: Colors.orangeAccent,
              onChanged: (v) => ctrl.toggleBifocal(v),
            ),
            if (ctrl.isBifocal) ...[
              IconButton(
                icon: const Icon(Icons.arrow_drop_up, color: Colors.white),
                onPressed: () => ctrl.adjustBifocalLine(-5),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                onPressed: () => ctrl.adjustBifocalLine(5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[850],
      child: Consumer<OpticalController>(
        builder: (context, ctrl, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚙️ Calibración de Medidas",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Ajuste Horizontal
            Row(
              children: [
                const SizedBox(
                  width: 140,
                  child: Text(
                    "Ajuste Horizontal:",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: ctrl.ajusteHorizontal,
                    min: 0.8,
                    max: 1.2,
                    divisions: 40,
                    activeColor: Colors.cyanAccent,
                    onChanged: (v) => ctrl.setAjusteHorizontal(v),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    ctrl.ajusteHorizontal.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const Text(
              "  Afecta: DI, DNP, Puente, Ancho Aro, Diámetro",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),

            const SizedBox(height: 8),

            // Ajuste Vertical
            Row(
              children: [
                const SizedBox(
                  width: 140,
                  child: Text(
                    "Ajuste Vertical:",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: ctrl.ajusteVertical,
                    min: 0.8,
                    max: 1.2,
                    divisions: 40,
                    activeColor: Colors.greenAccent,
                    onChanged: (v) => ctrl.setAjusteVertical(v),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    ctrl.ajusteVertical.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const Text(
              "  Afecta: Alturas, Alto Aro",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),

            const SizedBox(height: 8),

            // Info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "ℹ️ Usa cruces INFERIORES (B1,B2) para horizontal y SUPERIORES (A1,A2) para vertical",
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return Consumer<OpticalController>(
      builder: (context, controller, _) {
        return InteractiveViewer(
          transformationController: _transformationController,
          maxScale: 5.0,
          minScale: 1.0,
          panEnabled: _isMoveMode,
          scaleEnabled: _isMoveMode,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double scaleX = constraints.maxWidth / _imageSize!.width;
              final double scaleY = constraints.maxHeight / _imageSize!.height;
              final double scale = scaleX < scaleY ? scaleX : scaleY;
              final double displayW = _imageSize!.width * scale;
              final double displayH = _imageSize!.height * scale;
              final double offsetX = (constraints.maxWidth - displayW) / 2;
              final double offsetY = (constraints.maxHeight - displayH) / 2;

              return GestureDetector(
                onPanDown: _isMoveMode
                    ? null
                    : (details) {
                        controller.handleTap(
                          details.localPosition,
                          scale,
                          Offset(offsetX, offsetY),
                        );
                      },
                onPanUpdate: _isMoveMode
                    ? null
                    : (details) {
                        controller.handleDrag(details.delta, scale);
                      },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.flip(
                      flipX: widget.isFrontCamera,
                      child: Image.file(_imageFile),
                    ),
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: OpticalPainter(
                        points: controller.points,
                        selectedPoint: controller.selectedPoint,
                        scale: scale,
                        offset: Offset(offsetX, offsetY),
                        showCircles: controller.showCircles,
                        refDiameterMm: controller.referenceCircleDiameter,
                        calcRadiusPxR: controller.calcRadiusPxRight,
                        calcRadiusPxL: controller.calcRadiusPxLeft,
                        pixelFactorX: controller.pixelFactorX,
                        pixelFactorY: controller.pixelFactorY,
                        isBifocal: controller.isBifocal,
                        bifocalOffset: controller.bifocalLineOffset,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNudgeControls() {
    return Consumer<OpticalController>(
      builder: (context, controller, child) {
        if (controller.selectedPoint == null || _isMoveMode) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _arrowButton(
                  Icons.keyboard_arrow_up,
                  () => controller.nudgeSelectedPoint(0, -1),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _arrowButton(
                      Icons.keyboard_arrow_left,
                      () => controller.nudgeSelectedPoint(-1, 0),
                    ),
                    const SizedBox(width: 40, height: 40),
                    _arrowButton(
                      Icons.keyboard_arrow_right,
                      () => controller.nudgeSelectedPoint(1, 0),
                    ),
                  ],
                ),
                _arrowButton(
                  Icons.keyboard_arrow_down,
                  () => controller.nudgeSelectedPoint(0, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback action) {
    return GestureDetector(
      onTapDown: (_) {
        action();
        _holdTimer = Timer.periodic(
          const Duration(milliseconds: 50),
          (_) => action(),
        );
      },
      onTapUp: (_) => _holdTimer?.cancel(),
      onTapCancel: () => _holdTimer?.cancel(),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Consumer<OpticalController>(
      builder: (context, ctrl, _) {
        return Container(
          color: const Color(0xFF121212),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem("IPD (DI)", ctrl.di, isLarge: true),
                  _statItem("Puente", ctrl.puente),
                  _statItem("Aro Anc", ctrl.aroAnc),
                  _statItem("Aro Alt", ctrl.aroAlt),
                ],
              ),
              const Divider(color: Colors.white24),
              Row(
                children: [
                  Expanded(
                    child: _eyeStat(
                      "Ojo Der (P1)",
                      ctrl.dnpRight,
                      ctrl.altRight,
                      ctrl.diametroRight,
                    ),
                  ),
                  Container(width: 1, height: 60, color: Colors.white24),
                  Expanded(
                    child: _eyeStat(
                      "Ojo Izq (P2)",
                      ctrl.dnpLeft,
                      ctrl.altLeft,
                      ctrl.diametroLeft,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String label, double value, {bool isLarge = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.white,
            fontSize: isLarge ? 28 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text("mm", style: TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _eyeStat(String side, double dnp, double height, double diam) {
    return Column(
      children: [
        Text(
          side,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "DNP: ${dnp.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          "Alt: ${height.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          "Diam: ${diam.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  void _showResultsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ResultsSheet(controller: _controller),
    );
  }
}

class _ResultsSheet extends StatelessWidget {
  final OpticalController controller;

  const _ResultsSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "📋 Resultados de Medición",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Measurements Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Medidas Generales",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 20),

                _resultRow(
                  "Distancia Interpupilar (DI)",
                  controller.di,
                  highlight: true,
                ),
                _resultRow("Puente", controller.puente),
                _resultRow("Ancho Aro", controller.aroAnc),
                _resultRow("Alto Aro", controller.aroAlt),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Eyes Measurements Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ojo Derecho (P1)",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _resultRow(
                        "DNP",
                        controller.dnpRight,
                        highlight: false,
                        compact: true,
                      ),
                      _resultRow(
                        "Altura",
                        controller.altRight,
                        highlight: false,
                        compact: true,
                      ),
                      _resultRow(
                        "Diámetro",
                        controller.diametroRight,
                        highlight: false,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ojo Izquierdo (P2)",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _resultRow(
                        "DNP",
                        controller.dnpLeft,
                        highlight: false,
                        compact: true,
                      ),
                      _resultRow(
                        "Altura",
                        controller.altLeft,
                        highlight: false,
                        compact: true,
                      ),
                      _resultRow(
                        "Diámetro",
                        controller.diametroLeft,
                        highlight: false,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Share Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text("Copiar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareResults(context),
                  icon: const Icon(Icons.share),
                  label: const Text("Compartir"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _resultRow(
    String label,
    double value, {
    bool highlight = false,
    bool compact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: compact ? 13 : 14,
            ),
          ),
          Text(
            "${value.toStringAsFixed(1)} mm",
            style: TextStyle(
              color: highlight ? Colors.cyanAccent : Colors.white,
              fontSize: compact ? 15 : 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getResultsText() {
    return """
📋 RESULTADOS DE MEDICIÓN ÓPTICA

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MEDIDAS GENERALES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👁️ Distancia Interpupilar (DI): ${controller.di.toStringAsFixed(1)} mm
🔗 Puente: ${controller.puente.toStringAsFixed(1)} mm
↔️  Ancho Aro: ${controller.aroAnc.toStringAsFixed(1)} mm
↕️  Alto Aro: ${controller.aroAlt.toStringAsFixed(1)} mm

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OJO DERECHO (P1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DNP: ${controller.dnpRight.toStringAsFixed(1)} mm
Altura: ${controller.altRight.toStringAsFixed(1)} mm
Diámetro: ${controller.diametroRight.toStringAsFixed(1)} mm

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OJO IZQUIERDO (P2)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DNP: ${controller.dnpLeft.toStringAsFixed(1)} mm
Altura: ${controller.altLeft.toStringAsFixed(1)} mm
Diámetro: ${controller.diametroLeft.toStringAsFixed(1)} mm

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Generado con Pupilómetro Digital
""";
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final text = _getResultsText();

    // 1. Copy to clipboard
    await Clipboard.setData(ClipboardData(text: text));

    // 2. Show confirmation
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Resultados copiados al portapapeles"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _shareResults(BuildContext context) async {
    final text = _getResultsText();

    // 1. Trigger native share dialog
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Resultados de Medición Óptica'),
    );

    // 2. Close sheet
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
