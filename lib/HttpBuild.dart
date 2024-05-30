import 'dart:convert';
import 'package:colyakapp/HomePage.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String genelUrl = 'https://api.colyakdiyabet.com.tr/';
String globaltoken = "";
String refreshToken = "";
String userName = "";
String storedEmail = "";
String storedPassword = "";

final http.Client client = http.Client();

Future<http.Response> sendRequest(
  String method,
  String path, {
  dynamic body,
  String? extra,
  String? token,
  required BuildContext context,
}) async {
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  try {
    final uri = Uri.parse("$genelUrl$path${extra ?? ''}");
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
      globaltoken = await postRefreshToken(context);
      return sendRequest(
        method,
        path,
        body: body,
        extra: extra,
        token: globaltoken,
        context: context,
      );
    } else {
      return http.Response.fromStream(response);
    }
  } catch (e) {
    print('İstek gönderirken hata oluştu: $e');
    rethrow;
  }
}

Future<void> checkAndLogin(BuildContext context) async {
  if (refreshToken.isNotEmpty) {
    try {
      var url = Uri.parse('${genelUrl}api/users/verify/refresh-token');
      var data = {'refreshToken': refreshToken};
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print(response.body);
        var data = jsonDecode(response.body);
        globaltoken = data["token"];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              "/loginscreen", (Route<dynamic> route) => false);
        });
      }
    } catch (e) {
      print('Hata! $e');
    }
  } else {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          "/loginscreen", (Route<dynamic> route) => false);
    });
  }
}

Future<String> postRefreshToken(BuildContext context) async {
  refreshToken = (await getStoredToken('refresh_token')) ?? '';
  final refTokenDetails = {'refreshToken': refreshToken};

  try {
    final postRefreshTokenResponse = await http.post(
      Uri.parse("${genelUrl}api/users/verify/refresh-token"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(refTokenDetails),
    );

    if (postRefreshTokenResponse.statusCode == 200) {
      final responseJson =
          jsonDecode(utf8.decode(postRefreshTokenResponse.bodyBytes));
      print(postRefreshTokenResponse.body);
      globaltoken = responseJson['token'];
      userName = responseJson['userName'];
      await saveTokensToPrefs(globaltoken, refreshToken, userName);
      return globaltoken;
    } else if (postRefreshTokenResponse.statusCode == 602) {
      await showSessionExpiredDialog(context);
      return '';
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

Future<void> showSessionExpiredDialog(BuildContext context) async {
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
                  context, "/loginscreen", (route) => false);
            },
          ),
        ],
      );
    },
  );
}

Future<void> saveTokensToPrefs(
    String globalToken, String refreshToken, String userName,
    {String? storedEmail, String? storedPassword, bool? isChecked}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', globalToken);
  await prefs.setString('refresh_token', refreshToken);
  await prefs.setString('userName', userName);
  if (storedEmail != null) {
    await prefs.setString('storedEmail', storedEmail);
  }
  if (storedPassword != null) {
    await prefs.setString('storedPassword', storedPassword);
  }
  if (isChecked != null) {
    await prefs.setBool('isChecked', isChecked);
  }
}

Future<String?> getStoredToken(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<bool?> getStoredBool(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}
