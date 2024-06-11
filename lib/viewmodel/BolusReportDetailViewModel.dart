import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:colyakapp/model/BolusJson.dart';

class BolusReportDetailViewModel extends ChangeNotifier {
  final BolusReportJson reportDetails;

  BolusReportDetailViewModel(this.reportDetails);

  String formatDateTime(String dateTime) {
    DateTime dt = DateTime.parse(dateTime);
    return DateFormat('dd/MM/yyyy - HH:mm').format(dt);
  }

  String formatEatingTime(DateTime? eatingTime) {
    if (eatingTime == null) return "Yok";
    return DateFormat('dd/MM/yyyy - HH:mm').format(eatingTime);
  }
}
