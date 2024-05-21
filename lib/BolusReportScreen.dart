import 'dart:convert';
import 'package:colyakapp/BolusJson.dart';
import 'package:colyakapp/BolusReportDetailScreen.dart';
import 'package:colyakapp/HttpBuild.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BolusReportScreen extends StatefulWidget {
  const BolusReportScreen({super.key});

  @override
  State<BolusReportScreen> createState() => _BolusReportScreenState();
}

class _BolusReportScreenState extends State<BolusReportScreen> {
  List<BolusReportJson> reportList = [];
  List<BolusReportJson> bolusReportList = [];
  bool isLoading = true;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  String tarihDonusum(String gelenDate) {
    DateTime dateTime = DateTime.parse(gelenDate);
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    String date = "$day/$month/$year";
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String time = "$hour:$minute";
    String total = "$date - $time";
    return total;
  }

  Future<void> raporCek(String start, String end) async {
    var response = await sendRequest(
        "GET", "api/meals/report/$storedEmail/$start/$end",
        token: globaltoken, context: context);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    if (mounted) {
      setState(() {
        reportList =
            data.map((json) => BolusReportJson.fromJson(json)).toList();
        bolusReportList = reportList.reversed.toList();
      });
    }
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var now = DateTime.now().add(const Duration(days: 1));
      var lastWeek = now.subtract(const Duration(days: 7));
      var dateFormat = DateFormat('yyyy-MM-dd');
      await raporCek(dateFormat.format(lastWeek), dateFormat.format(now));
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      DateTime initialDate,
      ValueChanged<DateTime> onDateChanged) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        onDateChanged(picked);
      });
    }
  }

  void _fetchReports() async {
    if (startDate != null && endDate != null) {
      setState(() {
        isLoading = true;
      });
      try {
        await raporCek(DateFormat('yyyy-MM-dd').format(startDate!),
            DateFormat('yyyy-MM-dd').format(endDate!));
      } catch (e) {
        print(e);
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bolus Raporları"),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_startDateController.text.isNotEmpty &&
                    _endDateController.text.isNotEmpty) {
                  _fetchReports();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Başlangıç veya bitiş tarihi boş olamaz!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }),
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
                      readOnly: true,
                      controller: _startDateController,
                      decoration: InputDecoration(
                        labelText: 'Başlangıç Tarihi',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () {
                            _selectDate(
                                context,
                                _startDateController,
                                DateTime.now()
                                    .subtract(const Duration(days: 7)),
                                (picked) {
                              startDate = picked;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: _endDateController,
                      decoration: InputDecoration(
                        labelText: 'Bitiş Tarihi',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () {
                            _selectDate(
                                context, _endDateController, DateTime.now(),
                                (picked) {
                              endDate = picked.add(const Duration(days: 1));
                            });
                          },
                        ),
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
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : bolusReportList.isEmpty
                      ? const Center(
                          child: Text("Rapor Yok"),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(5),
                          child: ListView.builder(
                            itemCount: bolusReportList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BolusReportDetailScreen(
                                              reportDetails:
                                                  bolusReportList[index]),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: ListTile(
                                      title: Text(
                                        tarihDonusum(
                                            bolusReportList[index].dateTime!),
                                      ),
                                      trailing:
                                          const Icon(Icons.arrow_forward)),
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
  }
}
