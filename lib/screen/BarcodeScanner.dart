import 'package:colyakapp/viewmodel/BarcodeScannerViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with SingleTickerProviderStateMixin {
  late BarcodeScannerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BarcodeScannerViewModel(this);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BarcodeScannerViewModel>.value(
      value: _viewModel,
      child: Consumer<BarcodeScannerViewModel>(
        builder: (context, viewModel, child) {
          final scanWindow = _getScanWindow(context);

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text('Barkod Tarayıcı'),
              actions: [_buildTorchButton(viewModel)],
            ),
            body: GestureDetector(
              onScaleStart: (_) => viewModel.onScaleStart(),
              onScaleUpdate: (details) =>
                  viewModel.onScaleUpdate(details.scale),
              onDoubleTap: () => viewModel.onDoubleTapZoom(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildScanner(viewModel, scanWindow, context),
                  _buildScannerOverlay(scanWindow, viewModel),
                ],
              ),
            ),
            floatingActionButton: _buildImagePickerButton(viewModel, context),
          );
        },
      ),
    );
  }

  Rect _getScanWindow(BuildContext context) {
    return Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.width / 2,
    );
  }

  Widget _buildTorchButton(BarcodeScannerViewModel viewModel) {
    return IconButton(
      color: Colors.black,
      iconSize: 32.0,
      icon: Icon(viewModel.isTorchOn ? Icons.flash_on : Icons.flash_off),
      onPressed: () async {
        viewModel.toggleTorch();
      },
    );
  }

  Widget _buildScanner(BarcodeScannerViewModel viewModel, Rect scanWindow,
      BuildContext context) {
    return Center(
      child: MobileScanner(
        fit: BoxFit.contain,
        controller: viewModel.controller,
        scanWindow: scanWindow,
        errorBuilder: (context, error, child) {
          return _buildErrorScreen(error);
        },
        onDetect: (barcodes) {
          final barcode = barcodes.barcodes.first.rawValue!;
          barcodes.barcodes.clear();
          viewModel.disposeController();
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

  Widget _buildScannerOverlay(
      Rect scanWindow, BarcodeScannerViewModel viewModel) {
    return CustomPaint(
      painter: ScannerOverlay(
        scanWindow: scanWindow,
        animationValue: viewModel.animation.value,
      ),
    );
  }

  Widget _buildImagePickerButton(
      BarcodeScannerViewModel viewModel, BuildContext context) {
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.image),
      iconSize: 32.0,
      onPressed: () async {
        viewModel.controller.stop();
        final barcode = await viewModel.analyzeImage(context);

        if (barcode != null) {
          Navigator.pop(context, barcode);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Barkod bulunamadı!'),
            backgroundColor: Colors.red,
          ));
          viewModel.controller.start();
        }
      },
    );
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
