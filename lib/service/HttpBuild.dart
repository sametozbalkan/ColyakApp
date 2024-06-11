import 'dart:convert';
import 'package:colyakapp/screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpBuildService {
  static String globaltoken = "";
  static String refreshToken = "";
  static String userName = "";
  static String storedEmail = "";

  static final http.Client client = http.Client();

  static Future<http.Response> sendRequest(
    String method,
    String path, {
    dynamic body,
    String? extra,
    bool? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token == true) 'Authorization': 'Bearer $globaltoken',
    };

    try {
      final uri =
          Uri.parse("https://api.colyakdiyabet.com.tr/$path${extra ?? ''}");
      final request = http.Request(method, uri)..headers.addAll(headers);

      if (body != null) {
        if (body is String) {
          request.body = body;
          request.headers['Content-Type'] = 'text/plain';
        } else {
          request.body = jsonEncode(body);
        }
      }

      final response = await client.send(request);

      if (response.statusCode == 401 || response.statusCode == 601) {
        globaltoken = await postRefreshToken();
        return sendRequest(
          method,
          path,
          body: body,
          extra: extra,
          token: token,
        );
      } else {
        return http.Response.fromStream(response);
      }
    } catch (e) {
      print('İstek gönderirken hata oluştu: $e');
      rethrow;
    }
  }

  static Future<void> checkAndLogin(BuildContext context) async {
    if (refreshToken.isNotEmpty) {
      var response = await _postWithJson(
        'https://api.colyakdiyabet.com.tr/api/users/verify/refresh-token',
        {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        globaltoken = data["token"];
        userName = data["userName"];
        _navigateToHomePage(context);
      } else {
        _navigateToLoginScreen(context);
      }
    } else {
      _navigateToLoginScreen(context);
    }
  }

  static Future<String?> getStoredToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> showSessionExpiredDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oturum Süresi Doldu'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Oturum süreniz doldu. Lütfen yeniden giriş yapın.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/loginscreen",
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> saveTokensToPrefs(
    String refreshToken, {
    String? storedEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('storedEmail', storedEmail ?? '');
  }

  static Future<String> postRefreshToken() async {
    refreshToken = (await getStoredToken('refresh_token')) ?? '';
    if (refreshToken.isEmpty) {
      throw Exception("Refresh token is null or empty.");
    }
    final refTokenDetails = {'refreshToken': refreshToken};

    try {
      final postRefreshTokenResponse = await _postWithJson(
        "https://api.colyakdiyabet.com.tr/api/users/verify/refresh-token",
        refTokenDetails,
      );

      if (postRefreshTokenResponse.statusCode == 200) {
        final responseJson = jsonDecode(postRefreshTokenResponse.body);
        globaltoken = responseJson['token'];
        return globaltoken;
      } else if (postRefreshTokenResponse.statusCode == 602) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          await showSessionExpiredDialog(context);
        } else {
          throw Exception("Navigator context is null.");
        }
        return "";
      } else {
        print(
            "Refresh token gönderilirken hata: ${postRefreshTokenResponse.statusCode}");
        throw Exception(
            "Refresh token gönderilirken hata: ${postRefreshTokenResponse.statusCode}");
      }
    } catch (e) {
      print("Refresh token gönderilirken kritik hata: $e");
      rethrow;
    }
  }

  static Future<http.Response> _postWithJson(
      String url, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );
    return response;
  }

  static void _navigateToHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  static void _navigateToLoginScreen(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          "/loginscreen", (Route<dynamic> route) => false);
    });
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
