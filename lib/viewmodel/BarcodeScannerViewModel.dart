import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class BarcodeScannerViewModel extends ChangeNotifier {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.ean13],
  );
  double _previousScale = 1.0;
  double _currentScale = 1.0;
  bool onDoubleTap = false;
  bool isTorchOn = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  double get currentScale => _currentScale;
  Animation<double> get animation => _animation;

  BarcodeScannerViewModel(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  void initialize() {
    controller.start();
  }

  void disposeController() {
    if (_animationController.isAnimating) {
      _animationController.dispose();
    }
    controller.dispose();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  void toggleTorch() async {
    await controller.toggleTorch();
    isTorchOn = !isTorchOn;
    notifyListeners();
  }

  void setZoomScale(double scale) {
    _currentScale = scale;
    controller.setZoomScale(scale);
    notifyListeners();
  }

  void onScaleStart() {
    _previousScale = _currentScale;
  }

  void onScaleUpdate(double scale) {
    _currentScale = (_previousScale * scale).clamp(0.0, 1.0);
    setZoomScale(_currentScale);
  }

  void onDoubleTapZoom() {
    if (onDoubleTap) {
      setZoomScale(0);
    } else {
      setZoomScale(0.5);
    }
    onDoubleTap = !onDoubleTap;
  }

  Future<String?> analyzeImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      controller.start();
      return null;
    }

    final BarcodeCapture? barcodes = await controller.analyzeImage(image.path);

    if (barcodes != null && barcodes.barcodes.isNotEmpty) {
      return barcodes.barcodes.first.rawValue;
    } else {
      return null;
    }
  }
}
