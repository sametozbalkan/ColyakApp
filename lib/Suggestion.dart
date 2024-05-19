
import 'package:colyakapp/HttpBuild.dart';
import 'package:flutter/material.dart';

class Suggestion extends StatefulWidget {
  const Suggestion({super.key});

  @override
  State<Suggestion> createState() => _SuggestionState();
}

class _SuggestionState extends State<Suggestion> {
  final TextEditingController urunOner = TextEditingController();

  void suggestionGonder(String suggestion) async {
    try {
      final suggestionDetails = {'suggestion': suggestion};
      final response = await sendRequest(
        'POST',
        'api/suggestions/add',
        body: suggestionDetails,
        token: globaltoken,
        context: context,
      );

      if (response.statusCode == 200) {
        showSnackBar('Ürün önerisi gönderildi!');
        Navigator.pop(context);
      } else {
        showSnackBar('Ürün önerilirken hata!',
            additionalMessage: response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  void showSnackBar(String message, {String? additionalMessage}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(additionalMessage != null
            ? '$message $additionalMessage'
            : message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öneri")
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Diyetisyeninize önermek istediğiniz bir ürün veya tarif mi var? Aşağıdaki boş alana önerinizi yazıp gönderebilirsiniz.",
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    maxLines: null,
                    controller: urunOner,
                    decoration: const InputDecoration(
                      labelText: "Ürün veya tarif öner",
                      prefixIcon: Icon(Icons.receipt),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    suggestionGonder(urunOner.text);
                  },
                  child: const Text("Gönder"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
