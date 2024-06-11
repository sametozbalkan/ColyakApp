import 'dart:convert';
import 'package:colyakapp/screen/VerifyMailScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/screen/HomePage.dart';

class LoginViewModel extends ChangeNotifier {
  bool isVisible = true;
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginViewModel() {
    deleteTokens();
  }

  Future<void> login(BuildContext context) async {
    Map<String, String> loginDetails = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    isLoading = true;
    notifyListeners();

    try {
      var postLogin = await HttpBuildService.sendRequest(
          "POST", "api/users/verify/login",
          body: loginDetails);

      isLoading = false;
      notifyListeners();

      if (postLogin.statusCode == 200) {
        Map<String, dynamic> responseJson =
            jsonDecode(utf8.decode(postLogin.bodyBytes));
        HttpBuildService.globaltoken = responseJson['token'];
        HttpBuildService.refreshToken = responseJson['refreshToken'];
        HttpBuildService.userName = responseJson['userName'];
        HttpBuildService.storedEmail = emailController.text;

        await HttpBuildService.saveTokensToPrefs(
          HttpBuildService.refreshToken,
          storedEmail: HttpBuildService.storedEmail,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else if (postLogin.statusCode == 631) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email veya şifre yanlış!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (postLogin.statusCode == 619) {
        String verifId = postLogin.body;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyMailScreen(verificationId: verifId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Giriş başarısız! Hata kodu: ${postLogin.statusCode}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş başarısız! $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void onEmailChanged(String value) {
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    notifyListeners();
  }

  void clearEmail() {
    emailController.clear();
    notifyListeners();
  }

  Future<void> deleteTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void toggleVisibility() {
    isVisible = !isVisible;
    notifyListeners();
  }
}
