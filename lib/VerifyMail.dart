import 'package:colyakapp/HttpBuild.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyMail extends StatefulWidget {
  final String? verificationId;
  const VerifyMail({super.key, this.verificationId});

  @override
  State<VerifyMail> createState() => _VerifyMailState();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _VerifyMailState extends State<VerifyMail> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

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
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/loginscreen',
          (route) => false,
        );
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/loginscreen',
                    (route) => false,
                  );
                },
                child: const Text('Evet'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  String get _verificationCode =>
      _controllers.map((controller) => controller.text).join();

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
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/images/colyak.png",
                    height: MediaQuery.of(context).size.width / 1.5,
                    width: MediaQuery.of(context).size.width / 1.5),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Tek Seferlik Email Onay Kodu"),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            _onCodeChanged(value, index);
                          },
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: const InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_verificationCode.length == 6) {
                      await emailDogrula(
                        widget.verificationId!,
                        _verificationCode,
                        "api/users/verify/verify-email",
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kod alanı eksik!'),
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
    );
  }
}
