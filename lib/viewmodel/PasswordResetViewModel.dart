import 'package:flutter/material.dart';
import 'package:colyakapp/service/HttpBuild.dart';

class PasswordResetViewModel extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> forgotPassword(BuildContext context, String email) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await HttpBuildService.sendRequest(
          'POST', 'api/users/verify/x0/',
          extra: email);

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-postanıza şifre sıfırlama linki gönderildi!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      } else if (response.statusCode == 404) {
        showToast(context, 'Email formatı yanlış veya bulunamadı!');
      } else if (response.statusCode == 500) {
        showToast(context, 'Girilen email kayıtlı değil!');
      } else {
        showToast(context, 'Hata: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Error resetting password: $e');
    }
  }

  void clearEmail() {
    emailController.clear();
    notifyListeners();
  }

  void onEmailChanged(String value) {
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black,
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
