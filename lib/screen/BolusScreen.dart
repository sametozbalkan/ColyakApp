import 'package:colyakapp/others/ColyakIcons.dart';
import 'package:colyakapp/viewmodel/BolusViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BolusScreen extends StatelessWidget {
  final double totalCarb;
  const BolusScreen({super.key, required this.totalCarb});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BolusViewModel(),
      child: Consumer<BolusViewModel>(
        builder: (context, viewModel, child) {
          viewModel.karbonhidratMiktariController.text = totalCarb.toString();
          return Scaffold(
            appBar: AppBar(title: const Text("Bolus Hesapla")),
            floatingActionButton: ValueListenableBuilder<bool>(
              valueListenable: viewModel.isFormComplete,
              builder: (context, isComplete, child) {
                return isComplete
                    ? FloatingActionButton(
                        onPressed: () {
                          viewModel.calculateAndSendBolus(context);
                        },
                        child: const Icon(Icons.send),
                      )
                    : Container();
              },
            ),
            body: GestureDetector(
              onTap: () =>
                  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      timePickerCard(viewModel.timeController, context),
                      bolusCard("Kan Şekeri", viewModel.kanSekeriController,
                          ColyakIcons.sugar_blood, "Açlık kan şekeri"),
                      bolusCard(
                          "Hedef Kan Şekeri",
                          viewModel.hedefKanSekeriController,
                          Icons.track_changes_outlined,
                          "Doktorun uygun gördüğü kan şekeri"),
                      bolusCard(
                          "Karbonhidrat Miktarı (g)",
                          viewModel.karbonhidratMiktariController,
                          ColyakIcons.carbohydrate,
                          "Öğünde alınan karbonhidrat miktarı"),
                      bolusCard(
                          "İnsulin/Karbonhidrat Oranı",
                          viewModel.insulinKarbonhidratOraniController,
                          Icons.percent,
                          "İnsulin/Karbonhidrat oranı"),
                      bolusCard(
                          "IDF (İnsulin Duyarlılık Faktörü)",
                          viewModel.idfController,
                          ColyakIcons.idf,
                          "İnsulin Duyarlılık Faktörü"),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
        leading: Icon(icon, size: 32),
        subtitle: Center(
          child: Text(information),
        ),
      ),
    );
  }

  Widget timePickerCard(
      TextEditingController controller, BuildContext context) {
    return Card(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Yemek Saati",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                onTap: () async {
                  String hours = "";
                  String minute = "";
                  TimeOfDay time = const TimeOfDay(hour: 0, minute: 0);
                  TimeOfDay? newTime = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (newTime == null) return;
                  hours = newTime.hour.toString().padLeft(2, "0");
                  minute = newTime.minute.toString().padLeft(2, "0");
                  controller.text = "$hours:$minute";
                },
                readOnly: true,
                controller: controller,
                decoration: InputDecoration(
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
        leading: const Icon(Icons.access_time, size: 32),
        subtitle: const Center(
          child: Text("Yemeği yediğin zaman"),
        ),
      ),
    );
  }
}
