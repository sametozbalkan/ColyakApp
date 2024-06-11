import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:colyakapp/model/BolusJson.dart';
import 'package:colyakapp/service/HttpBuild.dart';

class BolusReportViewModel extends ChangeNotifier {
  List<BolusReportJson> reportList = [];
  List<BolusReportJson> bolusReportList = [];
  bool isLoading = true;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  bool _isMounted = true;

  BolusReportViewModel() {
    initializeData();
  }

  @override
  void dispose() {
    _isMounted = false;
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
  }

  Future<void> fetchReports(String start, String end) async {
    try {
      var response = await HttpBuildService.sendRequest(
          "GET", "api/meals/report/${HttpBuildService.storedEmail}/$start/$end",
          token: true);
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      reportList = data.map((json) => BolusReportJson.fromJson(json)).toList();
      bolusReportList = reportList.reversed.toList();
    } catch (e) {
      if (_isMounted) {
        print(e);
      }
    } finally {
      if (_isMounted) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> initializeData() async {
    isLoading = true;
    notifyListeners();
    try {
      var now = DateTime.now();
      var lastWeek = now.subtract(const Duration(days: 7));
      var dateFormat = DateFormat('yyyy-MM-dd');
      await fetchReports(dateFormat.format(lastWeek), dateFormat.format(now.add(const Duration(days: 1))));
    } catch (e) {
      if (_isMounted) {
        print(e);
      }
    } finally {
      if (_isMounted) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> selectDate(
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
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      onDateChanged(picked);
      if (_isMounted) {
        notifyListeners();
      }
    }
  }

  void fetchReportsForSelectedDates() async {
    if (startDate != null && endDate != null) {
      isLoading = true;
      notifyListeners();
      try {
        await fetchReports(
            DateFormat('yyyy-MM-dd').format(startDate!),
            DateFormat('yyyy-MM-dd').format(endDate!.add(const Duration(days: 1))));
      } catch (e) {
        if (_isMounted) {
          print(e);
        }
      } finally {
        if (_isMounted) {
          isLoading = false;
          notifyListeners();
        }
      }
    }
  }
}
