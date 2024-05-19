import 'dart:convert';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/PDFJson.dart';
import 'package:colyakapp/UserGuideScreen.dart';
import 'package:flutter/material.dart';

class UserGuides extends StatefulWidget {
  const UserGuides({super.key});

  @override
  State<UserGuides> createState() => _UserGuidesState();
}

class _UserGuidesState extends State<UserGuides> {
  bool isLoading = false;
  List<PDFJson> pdflistesi = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });
    await quizAl();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> quizAl() async {
    try {
      final response = await sendRequest('GET', "api/image/get/pdfListData2",
          token: globaltoken, context: context);

      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        pdflistesi = data.map((json) => PDFJson.fromJson(json)).toList();
      });
    } catch (e) {
      print('Failed to load pdf: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faydalı Bilgiler"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 5,
                  );
                },
                shrinkWrap: true,
                itemCount: pdflistesi.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserGuideScreen(
                            id: pdflistesi[index].id!,
                            name: pdflistesi[index].name!,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                          title: Text(pdflistesi[index].name!),
                          trailing: const Icon(Icons.arrow_forward)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
