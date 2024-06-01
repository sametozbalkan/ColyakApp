import 'dart:convert';
import 'package:colyakapp/VerifyMail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'HttpBuild.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

bool isCheckboxChecked = false;
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class _LoginScreenState extends State<LoginScreen> {
  bool isVisible = true;
  @override
  void initState() {
    super.initState();
    deleteTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/images/colyak.png",
                  height: MediaQuery.of(context).size.width / 1.5,
                  width: MediaQuery.of(context).size.width / 1.5),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Hoş Geldiniz",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onChanged: (_) => setState(() {}),
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                    suffixIcon: emailController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              emailController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onChanged: (_) => setState(() {}),
                  obscureText: isVisible,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: const Icon(Icons.password),
                    border: const OutlineInputBorder(),
                    suffixIcon: passwordController.text.isNotEmpty
                        ? IconButton(
                            icon: isVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() => isVisible = !isVisible);
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/forgotpassword");
                      },
                      child: const Text("Şifrenizi mi unuttunuz?")),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                      value: isCheckboxChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isCheckboxChecked = value!;
                        });
                      }),
                  const Text("Beni Hatırla")
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  await _login(emailController.text, passwordController.text);
                },
                child: const Text("Giriş Yap"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Henüz bir hesabınız yok mu?"),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: const Text("Kayıt Ol")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(String email, String password) async {
    Map<String, String> loginDetails = {
      'email': email,
      'password': password,
    };
    try {
      var postLogin = await HttpBuildService.sendRequest("POST", "api/users/verify/login",
          body: loginDetails);
      if (postLogin.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(utf8.decode(postLogin.bodyBytes));
        print(responseJson);
        HttpBuildService.globaltoken = responseJson['token'];
        HttpBuildService.refreshToken = responseJson['refreshToken'];
        HttpBuildService.userName = responseJson['userName'];
        HttpBuildService.storedEmail = email;
        HttpBuildService.storedPassword = password;
        if (isCheckboxChecked) {
          await HttpBuildService.saveTokensToPrefs(HttpBuildService.globaltoken, HttpBuildService.refreshToken, HttpBuildService.userName,
              storedEmail: HttpBuildService.storedEmail,
              storedPassword: HttpBuildService.storedPassword,
              isChecked: isCheckboxChecked);
        } else {
          await HttpBuildService.saveTokensToPrefs(HttpBuildService.globaltoken, HttpBuildService.refreshToken, HttpBuildService.userName,
              isChecked: isCheckboxChecked);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else if (postLogin.statusCode == 631) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Column(
              children: [Text('Email veya şifre yanlış!')],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (postLogin.statusCode == 619) {
        String verifId = postLogin.body;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyMail(verificationId: verifId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [const Text('Giriş başarısız!'), Text(postLogin.body)],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            children: [const Text('Giriş başarısız!'), Text(e.toString())],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> deleteTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", "");
    await prefs.setString("refresh_token", "");
    await prefs.setString("userName", "");
  }
}
