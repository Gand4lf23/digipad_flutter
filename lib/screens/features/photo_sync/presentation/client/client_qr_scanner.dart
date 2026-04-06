import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// QR code scanner widget using mobile_scanner package.
/// Designed for simplicity: fills the screen with a camera preview
/// and a scanning overlay.
class ClientQrScanner extends StatefulWidget {
  final void Function(String data) onScanned;
  final VoidCallback onCancel;

  const ClientQrScanner({
    super.key,
    required this.onScanned,
    required this.onCancel,
  });

  @override
  State<ClientQrScanner> createState() => _ClientQrScannerState();
}

class _ClientQrScannerState extends State<ClientQrScanner> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.contains('"ssid"')) {
        _hasScanned = true;
        // Haptic feedback
        widget.onScanned(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera preview
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        // Overlay with cutout
        _buildScanOverlay(context),
        // Bottom instruction
        Positioned(
          bottom: 80,
          left: 32,
          right: 32,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Apuntá al código QR del tótem',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanAreaSize = screenSize.width * 0.7;

    return CustomPaint(
      size: screenSize,
      painter: _ScanOverlayPainter(
        scanAreaSize: scanAreaSize,
        borderColor: const Color(0xFF00BFA6),
      ),
    );
  }
}

/// Custom painter for the scanning overlay with animated corners.
class _ScanOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final Color borderColor;

  _ScanOverlayPainter({
    required this.scanAreaSize,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);
    final halfSize = scanAreaSize / 2;
    final rect = Rect.fromCenter(
      center: center,
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Dark overlay
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    // Corner brackets
    final cornerLength = 32.0;
    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final left = center.dx - halfSize;
    final top = center.dy - halfSize;
    final right = center.dx + halfSize;
    final bottom = center.dy + halfSize;

    // Top-left
    canvas.drawLine(
        Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(
        Offset(left, top), Offset(left + cornerLength, top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(right - cornerLength, top), Offset(right, top),
        cornerPaint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, bottom - cornerLength), Offset(left, bottom),
        cornerPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom),
        cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(right - cornerLength, bottom),
        Offset(right, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom),
        Offset(right, bottom - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
