import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.ean13],
  );

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.width / 2,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Barkod Tarayıcı'),
        actions: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, state, child) {
              if (!state.isInitialized || !state.isRunning) {
                return const SizedBox.shrink();
              }

              switch (state.torchState) {
                case TorchState.auto:
                  return IconButton(
                    color: Colors.black,
                    iconSize: 32.0,
                    icon: const Icon(Icons.flash_auto),
                    onPressed: () async {
                      await controller.toggleTorch();
                    },
                  );
                case TorchState.off:
                  return IconButton(
                    color: Colors.black,
                    iconSize: 32.0,
                    icon: const Icon(Icons.flash_off),
                    onPressed: () async {
                      await controller.toggleTorch();
                    },
                  );
                case TorchState.on:
                  return IconButton(
                    color: Colors.black,
                    iconSize: 32.0,
                    icon: const Icon(Icons.flash_on),
                    onPressed: () async {
                      await controller.toggleTorch();
                    },
                  );
                case TorchState.unavailable:
                  return const Icon(
                    Icons.no_flash,
                    color: Colors.grey,
                  );
              }
            },
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: MobileScanner(
              fit: BoxFit.contain,
              controller: controller,
              scanWindow: scanWindow,
              errorBuilder: (context, error, child) {
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
                          error.errorDetails!.message!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          error.errorDetails?.message ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
              overlayBuilder: (context, constraints) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Ürünün barkodunu tarayın!',
                      overflow: TextOverflow.fade,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              onDetect: (barcodes) {
                String barkod = "";
                barkod = barcodes.barcodes.first.rawValue!;
                barcodes.barcodes.clear();
                controller.dispose();
                Navigator.pop(context, barkod);
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              if (!value.isInitialized ||
                  !value.isRunning ||
                  value.error != null) {
                return const SizedBox();
              }

              return CustomPaint(
                painter: ScannerOverlay(scanWindow: scanWindow),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
