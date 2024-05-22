import 'package:colyakapp/HttpBuild.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyMail extends StatefulWidget {
  final String? verificationId;
  const VerifyMail({super.key, this.verificationId});

  @override
  State<VerifyMail> createState() => _VerifyMailState();
}

class _VerifyMailState extends State<VerifyMail> {
  TextEditingController oneTimeCodeController = TextEditingController();

  Future<void> emailDogrula(
      String verificationId, String oneTimeCode, String path) async {
    Map<String, String> emailVerify = {
      "verificationId": verificationId,
      "oneTimeCode": oneTimeCode,
    };

    try {
      var emailVer =
          await sendRequest("POST", path, body: emailVerify, context: context);

      if (emailVer.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/loginscreen', (Route<dynamic> route) => false);
      } else {
        throw Exception("Email doğrulama başarısız oldu: ${emailVer.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email doğrulama başarısız oldu: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Emin misiniz?'),
            content: const Text(
                'Bu sayfadan ayrılırsanız üyeliğiniz onaylanmayacak ve sonradan onaylamanız gerekecek. Devam etmek istediğinize emin misiniz?',
                softWrap: true),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hayır'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/loginscreen', (Route<dynamic> route) => false);
                },
                child: const Text('Evet'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Email Doğrulama'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              bool shouldPop = await _onWillPop();
              if (shouldPop) {
                _onWillPop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      onChanged: (_) => setState(() {}),
                      controller: oneTimeCodeController,
                      decoration: InputDecoration(
                        labelText: "Tek Seferlik Kod",
                        border: const OutlineInputBorder(),
                        suffixIcon: oneTimeCodeController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  oneTimeCodeController.clear();
                                  setState(() {});
                                },
                              ),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (oneTimeCodeController.text.isNotEmpty) {
                        await emailDogrula(
                          widget.verificationId!,
                          oneTimeCodeController.text,
                          "api/users/verify/verify-email",
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kod alanı boş!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: const Text('Kaydı Tamamla'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
