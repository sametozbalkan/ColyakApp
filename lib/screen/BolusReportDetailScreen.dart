import 'package:colyakapp/model/BolusJson.dart';
import 'package:colyakapp/viewmodel/BolusReportDetailViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BolusReportDetailScreen extends StatelessWidget {
  final BolusReportJson reportDetails;

  const BolusReportDetailScreen({super.key, required this.reportDetails});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BolusReportDetailViewModel(reportDetails),
      child: Consumer<BolusReportDetailViewModel>(
        builder: (context, viewModel, child) {
          final bolus = reportDetails.bolus;
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.formatDateTime(reportDetails.dateTime!)),
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
                                    "Kullanıcı Adı", reportDetails.userName!),
                                _buildInfoRow(
                                    "Yeme Zamanı",
                                    bolus!.eatingTime != null
                                        ? viewModel
                                            .formatEatingTime(bolus.eatingTime)
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
                                _buildInfoRow("Bolus Miktarı",
                                    bolus.bolusValue.toString()),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        reportDetails.foodResponseList!.isNotEmpty
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
                      itemCount: reportDetails.foodResponseList?.length ?? 0,
                      itemBuilder: (context, foodIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: _buildFoodItem(
                              reportDetails.foodResponseList![foodIndex]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildFoodItem(FoodResponseList food) {
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
            Text(
                "Karbonhidrat: ${food.carbonhydrate?.toStringAsFixed(2)} gram"),
          ],
        ),
      ),
    );
  }
}
