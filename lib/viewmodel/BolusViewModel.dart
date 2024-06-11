import 'package:flutter/material.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/model/BolusJson.dart';

class BolusViewModel extends ChangeNotifier {
  final TextEditingController kanSekeriController = TextEditingController();
  final TextEditingController hedefKanSekeriController = TextEditingController();
  final TextEditingController insulinKarbonhidratOraniController = TextEditingController();
  final TextEditingController idfController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController karbonhidratMiktariController = TextEditingController();

  final ValueNotifier<bool> isFormComplete = ValueNotifier(false);

  BolusViewModel() {
    kanSekeriController.addListener(checkFormCompletion);
    hedefKanSekeriController.addListener(checkFormCompletion);
    insulinKarbonhidratOraniController.addListener(checkFormCompletion);
    idfController.addListener(checkFormCompletion);
    timeController.addListener(checkFormCompletion);
    karbonhidratMiktariController.addListener(checkFormCompletion);
  }

  void checkFormCompletion() {
    bool isComplete = kanSekeriController.text.isNotEmpty &&
        hedefKanSekeriController.text.isNotEmpty &&
        insulinKarbonhidratOraniController.text.isNotEmpty &&
        idfController.text.isNotEmpty &&
        karbonhidratMiktariController.text.isNotEmpty &&
        timeController.text.isNotEmpty;
    isFormComplete.value = isComplete;
  }

  Future<void> sendBolus(BolusJson bolusJson) async {
    try {
      final response = await HttpBuildService.sendRequest(
          'POST', 'api/meals/add',
          body: bolusJson.toJson(), token: true);

      if (response.statusCode == 201) {
        print("Başarılı");
      } else {
        throw Exception('Rapor gönderilirken hata!');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  DateTime getSelectedDateTime() {
    String time = timeController.text;
    List<String> splitTime = time.split(':');
    int hours = int.parse(splitTime[0]);
    int minutes = int.parse(splitTime[1]);

    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hours, minutes);
  }

  void calculateAndSendBolus(BuildContext context) async {
    if (karbonhidratMiktariController.text.isNotEmpty &&
        insulinKarbonhidratOraniController.text.isNotEmpty &&
        kanSekeriController.text.isNotEmpty &&
        hedefKanSekeriController.text.isNotEmpty &&
        idfController.text.isNotEmpty) {
      double? bloodSugar = tryParseDouble(kanSekeriController.text);
      double? targetBloodSugar = tryParseDouble(hedefKanSekeriController.text);
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
        double bolusValue = ((totalCarbonhydrate / insulinCarbonhydrateRatio) +
                (bloodSugar - targetBloodSugar)) /
            insulinTolerateFactor;

        BolusJson bolusDegerleri = BolusJson(
          foodList: [],
          bolus: Bolus(
            bloodSugar: bloodSugar.round().toInt(),
            targetBloodSugar: targetBloodSugar.round().toInt(),
            insulinTolerateFactor: insulinTolerateFactor.round().toInt(),
            totalCarbonhydrate: totalCarbonhydrate.round().toInt(),
            insulinCarbonhydrateRatio:
                insulinCarbonhydrateRatio.round().toInt(),
            bolusValue: bolusValue.round().toInt(),
            eatingTime: getSelectedDateTime(),
          ),
        );

        await sendBolus(bolusDegerleri);
        showBolusResult(context, bolusValue);
        clearFields();
      }
    } else {
      showValidationError(context);
    }
  }

  void showBolusResult(BuildContext context, double bolusValue) {
    showModalBottomSheet(
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
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text('Bolus Sonucu'),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'İnsülin Dozu: ${bolusValue.round().toInt()}',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showValidationError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hata"),
          content: const Text("Tüm alanları doldurduğunuzdan emin olun!"),
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

  void clearFields() {
    kanSekeriController.clear();
    hedefKanSekeriController.clear();
    insulinKarbonhidratOraniController.clear();
    idfController.clear();
    karbonhidratMiktariController.clear();
    timeController.clear();
    notifyListeners();
  }

  double? tryParseDouble(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return double.tryParse(value);
  }
}
