import 'package:colyakapp/others/ColyakIcons.dart';
import 'package:colyakapp/viewmodel/BolusFoodListViewModel.dart';
import 'package:colyakapp/viewmodel/BolusViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BolusScreen extends StatelessWidget {
  const BolusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BolusViewModel(),
      child: Consumer<BolusViewModel>(
        builder: (context, viewModel, child) {
          final bolusModel = Provider.of<BolusFoodListViewModel>(context);
          viewModel.karbonhidratMiktariController.text =
              bolusModel.totalCarb.toString();
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
                      TimePickerCard(controller: viewModel.timeController),
                      BolusCard(
                          title: "Kan Şekeri",
                          controller: viewModel.kanSekeriController,
                          icon: ColyakIcons.sugar_blood,
                          information: "Açlık kan şekeri"),
                      BolusCard(
                          title: "Hedef Kan Şekeri",
                          controller: viewModel.hedefKanSekeriController,
                          icon: Icons.track_changes_outlined,
                          information: "Doktorun uygun gördüğü kan şekeri"),
                      BolusCard(
                          title: "Karbonhidrat Miktarı (g)",
                          controller: viewModel.karbonhidratMiktariController,
                          icon: ColyakIcons.carbohydrate,
                          information: "Öğünde alınan karbonhidrat miktarı"),
                      BolusCard(
                          title: "İnsulin/Karbonhidrat Oranı",
                          controller:
                              viewModel.insulinKarbonhidratOraniController,
                          icon: Icons.percent,
                          information: "İnsulin/Karbonhidrat oranı"),
                      BolusCard(
                          title: "IDF (İnsulin Duyarlılık Faktörü)",
                          controller: viewModel.idfController,
                          icon: ColyakIcons.idf,
                          information: "İnsulin Duyarlılık Faktörü"),
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
}

class TimePickerCard extends StatelessWidget {
  final TextEditingController controller;

  const TimePickerCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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

class BolusCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final IconData icon;
  final String information;

  const BolusCard({
    super.key,
    required this.title,
    required this.controller,
    required this.icon,
    required this.information,
  });

  @override
  Widget build(BuildContext context) {
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
}
