import 'package:colyakapp/screen/VerifyMailScreen.dart';
import 'package:flutter/material.dart';
import 'package:colyakapp/service/HttpBuild.dart';

class RegisterViewModel extends ChangeNotifier {
  bool isVisible = true;
  bool isVisibleRepeat = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordControllerRepeat =
      TextEditingController();

  Future<void> register(BuildContext context, String path) async {
    Map<String, dynamic> registerDetails = {
      'email': emailController.text,
      'name': nameController.text,
      'password': passwordController.text,
    };

    try {
      var registerResponse = await HttpBuildService.sendRequest('POST', path,
          body: registerDetails);

      if (registerResponse.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerifyMailScreen(verificationId: registerResponse.body),
          ),
        );
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void toggleVisibility() {
    isVisible = !isVisible;
    notifyListeners();
  }

  void toggleVisibilityRepeat() {
    isVisibleRepeat = !isVisibleRepeat;
    notifyListeners();
  }

  bool isPasswordValid() {
    return passwordController.text.length >= 8;
  }

  bool arePasswordsMatching() {
    return passwordController.text == passwordControllerRepeat.text;
  }

  bool areFieldsNotEmpty() {
    return emailController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        passwordControllerRepeat.text.isNotEmpty;
  }
}
