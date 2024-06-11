import 'package:colyakapp/viewmodel/ShimmerViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Shimmer extends StatelessWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShimmerViewModel(context as TickerProvider),
      child: Consumer<ShimmerViewModel>(
        builder: (context, viewModel, child) {
          return AnimatedBuilder(
            animation: viewModel.shimmerAnimation,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: const Alignment(-1, -0.3),
                    end: const Alignment(1, 0.3),
                    colors: [
                      Colors.grey.shade300,
                      Colors.grey.shade100,
                      Colors.grey.shade300
                    ],
                    stops: [
                      viewModel.shimmerAnimation.value - 0.3,
                      viewModel.shimmerAnimation.value,
                      viewModel.shimmerAnimation.value + 0.3,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: this.child,
              );
            },
            child: this.child,
          );
        },
      ),
    );
  }
}
