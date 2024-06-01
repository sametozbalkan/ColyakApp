import 'package:colyakapp/HomePage.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/LoginScreen.dart';
import 'package:colyakapp/PasswordResetScreen.dart';
import 'package:colyakapp/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
          cardTheme: const CardTheme(color: Colors.white, elevation: 4),
          dividerTheme: const DividerThemeData(color: Colors.grey),
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
      ],
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
    isCheckboxChecked = (await HttpBuildService.getStoredBool('isChecked')) ?? false;
    if (isCheckboxChecked) {
      HttpBuildService.refreshToken = (await HttpBuildService.getStoredToken('refresh_token')) ?? '';
      HttpBuildService.userName = (await HttpBuildService.getStoredToken('userName')) ?? '';
      HttpBuildService.storedEmail = (await HttpBuildService.getStoredToken('storedEmail')) ?? '';
      HttpBuildService.storedPassword = (await HttpBuildService.getStoredToken('storedPassword')) ?? '';
      emailController.text = HttpBuildService.storedEmail;
      passwordController.text = HttpBuildService.storedPassword;
    }
    await HttpBuildService.checkAndLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/colyak.png",
                height: MediaQuery.of(context).size.width / 1.5,
                width: MediaQuery.of(context).size.width / 1.5),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
