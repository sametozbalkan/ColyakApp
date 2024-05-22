import 'package:colyakapp/HomePage.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/LoginScreen.dart';
import 'package:colyakapp/PasswordResetScreen.dart';
import 'package:colyakapp/RegisterScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/loginscreen': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/homepage': (context) => const HomePage(),
        '/forgotpassword': (context) => const PasswordResetScreen(),
      },
      title: 'Colyak App',
      theme: ThemeData(
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFFF7A37),
              foregroundColor: Colors.white),
          elevatedButtonTheme: const ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xFFFF7A37)),
                  foregroundColor: WidgetStatePropertyAll(Colors.white))),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFFFF7A37),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54),
          appBarTheme: const AppBarTheme(
              surfaceTintColor: Colors.white,
              color: Colors.white,
              titleTextStyle: TextStyle(
                  color: Colors.black, fontSize: 22, fontFamily: "Poppins"),
              centerTitle: true),
          fontFamily: "Poppins",
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7A37))
              .copyWith(background: const Color(0xFFFAFAFA)),
          useMaterial3: true),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getAll();
  }

  Future<void> getAll() async {
    refreshToken = (await getStoredToken('refresh_token')) ?? '';
    userName = (await getStoredToken('userName')) ?? '';
    isCheckboxChecked = (await getStoredBool('isChecked')) ?? false;
    storedEmail = (await getStoredToken('storedEmail')) ?? '';
    storedPassword = (await getStoredToken('storedPassword')) ?? '';
    if (isCheckboxChecked) {
      emailController.text = storedEmail;
      passwordController.text = storedPassword;
    }
    await checkAndLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/colyak.png"),
            const Text("Yükleniyor..."),
            const SizedBox(height: 5),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
