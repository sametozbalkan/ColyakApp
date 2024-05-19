import 'dart:convert';
import 'package:colyakapp/BolusJson.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:colyakapp/MealDetailScreen.dart';
import 'package:colyakapp/MealScreen.dart';
import 'package:flutter/material.dart';

class BolusScreen extends StatefulWidget {
  const BolusScreen({super.key});

  @override
  State<BolusScreen> createState() => _BolusScreenState();
}

final TextEditingController karbonhidratMiktariController =
    TextEditingController();

class _BolusScreenState extends State<BolusScreen> {
  final TextEditingController kanSekeriController = TextEditingController();
  final TextEditingController hedefKanSekeriController =
      TextEditingController();
  final TextEditingController insulinKarbonhidratOraniController =
      TextEditingController();
  final TextEditingController idfController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  TimeOfDay time = const TimeOfDay(hour: 10, minute: 30);

  Future<void> sendBolus(BolusJson bolusJson) async {
    try {
      final response = await sendRequest('POST', 'api/meals/add',
          body: bolusJson.toJson(), token: globaltoken, context: context);
      if (response.statusCode == 201) {
        BolusJson responseBolusJson =
            BolusJson.fromJson(json.decode(response.body));
        print('Response received: ${responseBolusJson.toJson()}');
      } else {
        throw Exception('Failed to send data');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  double bolusValue = 0;
  @override
  Widget build(BuildContext context) {
    String hours = "";
    String minute = "";

    return Scaffold(
      appBar: AppBar(title: const Text("Bolus Hesapla")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (karbonhidratMiktariController.text.isNotEmpty &&
              insulinKarbonhidratOraniController.text.isNotEmpty &&
              kanSekeriController.text.isNotEmpty &&
              hedefKanSekeriController.text.isNotEmpty &&
              idfController.text.isNotEmpty) {
            double? bloodSugar = tryParseDouble(kanSekeriController.text);
            double? targetBloodSugar =
                tryParseDouble(hedefKanSekeriController.text);
            double? insulinTolerateFactor = tryParseDouble(idfController.text);
            double? totalCarbonhydrate =
                tryParseDouble(karbonhidratMiktariController.text);
            double? insulinCarbonhydrateRatio =
                tryParseDouble(insulinKarbonhidratOraniController.text);

            if (bloodSugar != null &&
                targetBloodSugar != null &&
                insulinTolerateFactor != null &&
                totalCarbonhydrate != null &&
                insulinCarbonhydrateRatio != null) {
              bolusValue = ((totalCarbonhydrate / insulinCarbonhydrateRatio) +
                      (bloodSugar - targetBloodSugar)) /
                  insulinTolerateFactor;
              BolusJson bolusDegerleri = BolusJson(
                foodList: bolusFoodList,
                bolus: Bolus(
                  bloodSugar: bloodSugar.round().toInt(),
                  targetBloodSugar: targetBloodSugar.round().toInt(),
                  insulinTolerateFactor: insulinTolerateFactor.round().toInt(),
                  totalCarbonhydrate: totalCarbonhydrate.round().toInt(),
                  insulinCarbonhydrateRatio:
                      insulinCarbonhydrateRatio.round().toInt(),
                  bolusValue: bolusValue.round().toInt(),
                ),
              );
              await sendBolus(bolusDegerleri);
              await showModalBottomSheet<dynamic>(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      left: 10,
                      right: 10,
                      top: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('Bolus Sonucu'),
                        const SizedBox(height: 10),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Vurulacak doz: ${bolusValue.round().toInt()}',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
              setState(() {
                karbonhidratMiktariController.clear();
                kanSekeriController.clear();
                hedefKanSekeriController.clear();
                insulinKarbonhidratOraniController.clear();
                idfController.clear();
                bolusValue = 0;
                bolusFoodList.clear();
                foodListComplex.clear();
                timeController.clear();
              });
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Hata"),
                  content:
                      const Text("Tüm alanları doldurduğunuzdan emin olun!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Tamam"),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const Icon(Icons.send),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Yemek Saati",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          readOnly: true,
                          controller: timeController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () async {
                                  TimeOfDay? newTime = await showTimePicker(
                                    context: context,
                                    initialTime: time,
                                  );
                                  if (newTime == null) return;
                                  setState(() {
                                    time = newTime;
                                    hours =
                                        time.hour.toString().padLeft(2, "0");
                                    minute =
                                        time.minute.toString().padLeft(2, "0");
                                    timeController.text = "$hours:$minute";
                                  });
                                },
                                icon: const Icon(Icons.access_time)),
                            hintText: "Saat ve Dakika Seçin",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12.0),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  leading: const Icon(Icons.access_time),
                  subtitle: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Yemeği yediğin zaman"),
                    ],
                  ),
                ),
              ),
              bolusCard("Kan Şekeri", kanSekeriController, Icons.abc,
                  "Açlık kan şekeri"),
              bolusCard("Hedef Kan Şekeri", hedefKanSekeriController, Icons.abc,
                  "Doktorun uygun gördüğü kan şekeri"),
              bolusCard(
                  "Karbonhidrat Miktarı (g)",
                  karbonhidratMiktariController,
                  Icons.abc,
                  "Öğünde alınan karbonhidrat miktarı"),
              bolusCard(
                  "İnsulin/Karbonhidrat Oranı",
                  insulinKarbonhidratOraniController,
                  Icons.abc,
                  "İnsulin/Karbonhidrat oranı"),
              bolusCard("IDF (İnsulin Duyarlılık Faktörü)", idfController,
                  Icons.abc, "İnsulin Duyarlılık Faktörü"),
            ],
          ),
        ),
      ),
    );
  }

  Widget bolusCard(String title, TextEditingController controller,
      IconData icon, String information) {
    return Card(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        leading: Icon(icon),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(information),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: BolusScreen(),
  ));
}

double? tryParseDouble(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return double.tryParse(value);
}