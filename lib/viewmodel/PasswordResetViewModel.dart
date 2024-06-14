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
          body: {'email': email});

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-postanıza şifre sıfırlama linki gönderildi!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
            "/loginscreen", (Route<dynamic> route) => false);
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email formatı yanlış veya bulunamadı!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${response.statusCode}'),
            duration: const Duration(seconds: 1),
          ),
        );
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
}
