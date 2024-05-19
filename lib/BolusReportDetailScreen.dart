
import 'package:colyakapp/BolusJson.dart';
import 'package:flutter/material.dart';

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
                "Tür: ${food.foodType! == "RECEPIPT" ? "Tarif" : "Hazır Yiyecek"}"),
            Text("Karbonhidrat: ${food.carbonhydrate.toString()} gram"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Haftalık Bolus Raporları"),
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
                              widget.reportDetails.bolus!.eatingTime
                                  .toString()),
                          _buildInfoRow(
                              "Kan Şekeri",
                              widget.reportDetails.bolus!.bloodSugar
                                  .toString()),
                          _buildInfoRow(
                              "İnsülin/Karbonhidrat Oranı",
                              widget.reportDetails.bolus!
                                  .insulinCarbonhydrateRatio
                                  .toString()),
                          _buildInfoRow(
                              "İnsülin Tolerans Faktörü",
                              widget.reportDetails.bolus!.insulinTolerateFactor
                                  .toString()),
                          _buildInfoRow(
                              "Hedef Kan Şekeri",
                              widget.reportDetails.bolus!.targetBloodSugar
                                  .toString()),
                          _buildInfoRow(
                              "Bolus",
                              widget.reportDetails.bolus!.bolusValue
                                  .toString()),
                          _buildInfoRow(
                              "Toplam Karbonhidrat (g)",
                              widget.reportDetails.bolus!.totalCarbonhydrate
                                  .toString()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Yiyecek Listesi:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.reportDetails.foodResponseList?.length ?? 0,
                itemBuilder: (context, foodIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
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
