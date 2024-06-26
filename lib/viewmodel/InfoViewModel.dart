import 'package:flutter/material.dart';

class InfoViewModel extends ChangeNotifier {
  PageController pageController = PageController();
  int currentPage = 0;

  void onPageChanged(int page) {
    currentPage = page;
    notifyListeners();
  }

  void goToPage(BuildContext context, int page) {
    if (page < 0) {
      return;
    }
    if (page >= 12) {
      Navigator.of(context).pop();
      return;
    }
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
