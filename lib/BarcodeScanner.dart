import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.ean13],
  );

  late AnimationController _animationController;
  double _previousScale = 1.0;
  double _currentScale = 1.0;
  bool onDoubleTap = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = _getScanWindow(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Barkod Tarayıcı'),
        actions: [_buildTorchButton()],
      ),
      body: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        onDoubleTap: _onDoubleTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildScanner(scanWindow),
            _buildScannerOverlay(scanWindow),
          ],
        ),
      ),
      floatingActionButton: _buildImagePickerButton(),
    );
  }

  Rect _getScanWindow(BuildContext context) {
    return Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.width / 2,
    );
  }

  Widget _buildTorchButton() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        return IconButton(
          color: Colors.black,
          iconSize: 32.0,
          icon: Icon(_getTorchIcon(state.torchState)),
          onPressed: () async {
            await controller.toggleTorch();
          },
        );
      },
    );
  }

  IconData _getTorchIcon(TorchState torchState) {
    switch (torchState) {
      case TorchState.auto:
        return Icons.flash_auto;
      case TorchState.off:
        return Icons.flash_off;
      case TorchState.on:
        return Icons.flash_on;
      case TorchState.unavailable:
        return Icons.no_flash;
    }
  }

  Widget _buildScanner(Rect scanWindow) {
    return Center(
      child: MobileScanner(
        fit: BoxFit.contain,
        controller: controller,
        scanWindow: scanWindow,
        errorBuilder: (context, error, child) {
          return _buildErrorScreen(error);
        },
        onDetect: (barcodes) {
          final barcode = barcodes.barcodes.first.rawValue!;
          barcodes.barcodes.clear();
          controller.dispose();
          Navigator.pop(context, barcode);
        },
      ),
    );
  }

  Widget _buildErrorScreen(MobileScannerException error) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              error.errorDetails?.message ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(Rect scanWindow) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }
        return CustomPaint(
          painter: ScannerOverlay(
            scanWindow: scanWindow,
            animationValue: _animationController.value,
          ),
        );
      },
    );
  }

  Widget _buildImagePickerButton() {
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.image),
      iconSize: 32.0,
      onPressed: () async {
        controller.stop();
        final ImagePicker picker = ImagePicker();

        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image == null) {
          controller.start();
          return;
        }

        final BarcodeCapture? barcodes = await controller.analyzeImage(
          image.path,
        );

        if (!context.mounted) {
          controller.start();
          return;
        }

        barcodes != null
            ? Navigator.pop(context, barcodes.barcodes.first.rawValue)
            : {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Barkod bulunamadı!'),
                  backgroundColor: Colors.red,
                )),
                controller.start()
              };
      },
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = _currentScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _currentScale = (_previousScale * details.scale).clamp(0.0, 1.0);
      controller.setZoomScale(_currentScale);
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _previousScale = _currentScale;
  }

  void _onDoubleTap() {
    setState(() {
      if (onDoubleTap) {
        controller.setZoomScale(0);
      } else {
        controller.setZoomScale(0.5);
      }
      onDoubleTap = !onDoubleTap;
    });
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    required this.animationValue,
    this.borderRadius = 5,
  });

  final Rect scanWindow;
  final double borderRadius;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawOverlay(canvas, size);
    _drawBorder(canvas);
  }

  void _drawOverlay(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(_getBorderRect()),
    );

    canvas.drawPath(path, paint);
  }

  void _drawBorder(Canvas canvas) {
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(_getBorderRect(), borderPaint);
  }

  RRect _getBorderRect() {
    return RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius ||
        animationValue != oldDelegate.animationValue;
  }
}
