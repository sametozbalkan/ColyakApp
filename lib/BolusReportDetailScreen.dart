import 'package:colyakapp/BolusJson.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BolusReportDetailScreen extends StatefulWidget {
  final BolusReportJson reportDetails;
  const BolusReportDetailScreen({super.key, required this.reportDetails});

  @override
  State<BolusReportDetailScreen> createState() =>
      _BolusReportDetailScreenState();
}

class _BolusReportDetailScreenState extends State<BolusReportDetailScreen> {
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String tarihDonusum(String gelenDate) {
    DateTime dateTime = DateTime.parse(gelenDate);
    return DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
  }

  Widget _buildFoodItem(int foodIndex) {
    final food = widget.reportDetails.foodResponseList![foodIndex];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(
          food.foodName!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Tür: ${food.foodType! == "RECEIPT" ? "Tarif" : "Hazır Gıda"}"),
            Text("Karbonhidrat: ${food.carbonhydrate?.toStringAsFixed(2)} gram"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bolus = widget.reportDetails.bolus;
    return Scaffold(
      appBar: AppBar(
        title: Text(tarihDonusum(widget.reportDetails.dateTime!)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                              "Kullanıcı Adı", widget.reportDetails.userName!),
                          _buildInfoRow(
                              "Yeme Zamanı",
                              bolus!.eatingTime != null
                                  ? tarihDonusum(
                                      bolus.eatingTime!.toIso8601String())
                                  : "Yok"),
                          _buildInfoRow(
                              "Kan Şekeri", bolus.bloodSugar.toString()),
                          _buildInfoRow("Hedef Kan Şekeri",
                              bolus.targetBloodSugar.toString()),
                          _buildInfoRow("İnsülin/Karbonhidrat Oranı",
                              bolus.insulinCarbonhydrateRatio.toString()),
                          _buildInfoRow("İnsülin Tolerans Faktörü",
                              bolus.insulinTolerateFactor.toString()),
                          _buildInfoRow("Karbonhidrat (g)",
                              bolus.totalCarbonhydrate.toString()),
                          _buildInfoRow(
                              "Bolus Miktarı", bolus.bolusValue.toString()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  widget.reportDetails.foodResponseList!.isNotEmpty
                      ? const Text(
                          "Yiyecek Listesi:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.reportDetails.foodResponseList?.length ?? 0,
                itemBuilder: (context, foodIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: _buildFoodItem(foodIndex),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
