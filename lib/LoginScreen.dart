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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Çölyak Diyabet",
                    style: TextStyle(fontSize: 40),
                    softWrap: true,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Hoş Geldiniz",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
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
                      await _login(
                          emailController.text, passwordController.text);
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
          ],
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
      var postLogin = await sendRequest("POST", "api/users/verify/login",
          body: loginDetails, context: context);
print(postLogin.body);
      if (postLogin.statusCode == 200) {
        Map<String, dynamic> responseJson = json.decode(postLogin.body);
        globaltoken = responseJson['token'];
        refreshToken = responseJson['refreshToken'];
        userName = responseJson['userName'];
        if (isCheckboxChecked) {
          storedEmail = email;
          storedPassword = password;
          await saveTokensToPrefs(globaltoken, refreshToken, userName,
              storedEmail: storedEmail,
              storedPassword: storedPassword,
              isChecked: isCheckboxChecked);
        } else {
          await saveTokensToPrefs(globaltoken, refreshToken, userName,
              isChecked: isCheckboxChecked);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
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