import 'package:flutter/material.dart';

class ShimmerViewModel extends ChangeNotifier {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  ShimmerViewModel(TickerProvider vsync) {
    _controller =
        AnimationController(vsync: vsync, duration: const Duration(seconds: 2))
          ..repeat();
    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(_controller);
  }

  Animation<double> get shimmerAnimation => _shimmerAnimation;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
