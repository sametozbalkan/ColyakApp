import 'package:colyakapp/screen/HomePage.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/screen/LoginScreen.dart';
import 'package:colyakapp/screen/PasswordResetScreen.dart';
import 'package:colyakapp/screen/RegisterScreen.dart';
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
                  color: Colors.black, fontSize: 22, fontFamily: "Urbanist"),
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
    initializeData();
  }

  Future<void> initializeData() async {
    HttpBuildService.refreshToken =
        (await HttpBuildService.getStoredToken('refresh_token')) ?? '';
        HttpBuildService.storedEmail =
        (await HttpBuildService.getStoredToken('storedEmail')) ?? '';
    HttpBuildService.checkAndLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF7A37),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  "assets/images/colyak.png",
                  height: MediaQuery.of(context).size.width / 1.5,
                  width: MediaQuery.of(context).size.width / 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
