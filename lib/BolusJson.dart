class BolusJson {
  List<FoodList>? foodList;
  Bolus? bolus;
  String? dateTime;

  BolusJson({this.foodList, this.bolus, this.dateTime});

  BolusJson.fromJson(Map<String, dynamic> json) {
    if (json['foodList'] != null) {
      foodList = <FoodList>[];
      json['foodList'].forEach((v) {
        foodList!.add(FoodList.fromJson(v));
      });
    }
    bolus = json['bolus'] != null ? Bolus.fromJson(json['bolus']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (foodList != null) {
      data['foodList'] = foodList!.map((v) => v.toJson()).toList();
    }
    if (bolus != null) {
      data['bolus'] = bolus!.toJson();
    }
    return data;
  }
}

class FoodList {
  String? foodType;
  int? foodId;
  double? carbonhydrate;

  FoodList({this.foodType, this.foodId, this.carbonhydrate});

  FoodList.fromJson(Map<String, dynamic> json) {
    foodType = json['foodType'];
    foodId = json['foodId'];
    carbonhydrate = json['carbonhydrate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['foodType'] = foodType;
    data['foodId'] = foodId;
    data['carbonhydrate'] = carbonhydrate;
    return data;
  }
}

class FoodListComplex {
  String? foodName;
  String? type;
  String? foodType;
  int? foodId;
  int? amount;
  double? carbonhydrate;

  FoodListComplex({this.foodType, this.foodId, this.carbonhydrate, this.foodName, this.type, this.amount});
}

class Bolus {
  int? id;
  int? bloodSugar;
  int? targetBloodSugar;
  int? insulinTolerateFactor;
  int? totalCarbonhydrate;
  int? insulinCarbonhydrateRatio;
  int? bolusValue;
  DateTime? eatingTime;

  Bolus(
      {this.id,
      this.bloodSugar,
      this.targetBloodSugar,
      this.insulinTolerateFactor,
      this.totalCarbonhydrate,
      this.insulinCarbonhydrateRatio,
      this.bolusValue,
      this.eatingTime});

  Bolus.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bloodSugar = json['bloodSugar'];
    targetBloodSugar = json['targetBloodSugar'];
    insulinTolerateFactor = json['insulinTolerateFactor'];
    totalCarbonhydrate = json['totalCarbonhydrate'];
    insulinCarbonhydrateRatio = json['insulinCarbonhydrateRatio'];
    bolusValue = json['bolusValue'];
    eatingTime = json['eatingTime'] != null ? DateTime.parse(json['eatingTime']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bloodSugar'] = bloodSugar;
    data['targetBloodSugar'] = targetBloodSugar;
    data['insulinTolerateFactor'] = insulinTolerateFactor;
    data['totalCarbonhydrate'] = totalCarbonhydrate;
    data['insulinCarbonhydrateRatio'] = insulinCarbonhydrateRatio;
    data['bolusValue'] = bolusValue;
    data['eatingTime'] = eatingTime?.toIso8601String();
    return data;
  }
}

enum FoodType {
  RECEIPT,
  READYFOOD
}

class BolusReportJson {
  String? userName;
  List<FoodResponseList>? foodResponseList;
  Bolus? bolus;
  String? dateTime;

  BolusReportJson(
      {this.userName, this.foodResponseList, this.bolus, this.dateTime});

  BolusReportJson.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    if (json['foodResponseList'] != null) {
      foodResponseList = <FoodResponseList>[];
      json['foodResponseList'].forEach((v) {
        foodResponseList!.add(FoodResponseList.fromJson(v));
      });
    }
    bolus = json['bolus'] != null ? Bolus.fromJson(json['bolus']) : null;
    dateTime = json['dateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    if (foodResponseList != null) {
      data['foodResponseList'] =
          foodResponseList!.map((v) => v.toJson()).toList();
    }
    if (bolus != null) {
      data['bolus'] = bolus!.toJson();
    }
    data['dateTime'] = dateTime;
    return data;
  }
}

class FoodResponseList {
  String? foodType;
  double? carbonhydrate;
  String? foodName;

  FoodResponseList({this.foodType, this.carbonhydrate, this.foodName});

  FoodResponseList.fromJson(Map<String, dynamic> json) {
    foodType = json['foodType'];
    carbonhydrate = json['carbonhydrate'];
    foodName = json['foodName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['foodType'] = foodType;
    data['carbonhydrate'] = carbonhydrate;
    data['foodName'] = foodName;
    return data;
  }
}