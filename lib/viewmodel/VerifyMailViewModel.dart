import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:colyakapp/service/HttpBuild.dart';

class VerifyMailViewModel extends ChangeNotifier {
  final String? verificationId;
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  bool isPasteVisible = true;

  VerifyMailViewModel(this.verificationId);

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> handlePaste(BuildContext context) async {
    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      String pastedText = clipboardData.text!;
      if (pastedText.length == 6) {
        for (int i = 0; i < 6; i++) {
          controllers[i].text = pastedText[i];
        }
        FocusScope.of(context).unfocus();
        isPasteVisible = false;
        notifyListeners();
      }
    }
  }

  Future<void> verifyEmail(BuildContext context, String path) async {
    String oneTimeCode = controllers.map((controller) => controller.text).join();
    Map<String, String> emailVerify = {
      "verificationId": verificationId!,
      "oneTimeCode": oneTimeCode,
    };

    try {
      var emailVer = await HttpBuildService.sendRequest("POST", path, body: emailVerify);

      if (emailVer.statusCode == 200) {
        if (emailVer.body == "false") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hatalı kod!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
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
        }
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

  Future<bool> onWillPop(BuildContext context) async {
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

  void onCodeChanged(BuildContext context, String value, int index) {
    isPasteVisible = controllers.every((controller) => controller.text.isEmpty);
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
    notifyListeners();
  }
}
