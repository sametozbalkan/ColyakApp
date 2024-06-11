import 'package:colyakapp/screen/BolusReportDetailScreen.dart';
import 'package:colyakapp/viewmodel/BolusReportViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BolusReportScreen extends StatelessWidget {
  const BolusReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BolusReportViewModel(),
      child: Consumer<BolusReportViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Bolus Raporları"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: viewModel.fetchReportsForSelectedDates,
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onTap: () {
                              viewModel.selectDate(
                                  context,
                                  viewModel.startDateController,
                                  viewModel.startDate ?? DateTime.now().subtract(const Duration(days: 7)),
                                  (picked) {
                                viewModel.startDate = picked;
                              });
                            },
                            readOnly: true,
                            controller: viewModel.startDateController,
                            decoration: const InputDecoration(
                              labelText: 'Başlangıç Tarihi',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onTap: () {
                              viewModel.selectDate(
                                  context,
                                  viewModel.endDateController,
                                  viewModel.endDate ?? DateTime.now(),
                                  (picked) {
                                viewModel.endDate = picked;
                              });
                            },
                            readOnly: true,
                            controller: viewModel.endDateController,
                            decoration: const InputDecoration(
                              labelText: 'Bitiş Tarihi',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Raporlar",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : viewModel.bolusReportList.isEmpty
                            ? const Center(
                                child: Text("Rapor Yok"),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(5),
                                child: ListView.builder(
                                  itemCount: viewModel.bolusReportList.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BolusReportDetailScreen(
                                              reportDetails: viewModel.bolusReportList[index],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        child: ListTile(
                                          title: Text(
                                            viewModel.formatDate(viewModel.bolusReportList[index].dateTime!),
                                          ),
                                          trailing: const Icon(Icons.arrow_forward),
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
}
