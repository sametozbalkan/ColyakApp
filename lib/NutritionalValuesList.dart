class NutritionalValuesList {
  int? id;
  double? unit;
  String? type;
  double? carbohydrateAmount;
  double? proteinAmount;
  double? fatAmount;
  double? calorieAmount;

  NutritionalValuesList(
      {this.id,
      this.unit,
      this.type,
      this.carbohydrateAmount,
      this.proteinAmount,
      this.fatAmount,
      this.calorieAmount});

  NutritionalValuesList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unit = json['unit'];
    type = json['type'];
    carbohydrateAmount = json['carbohydrateAmount'];
    proteinAmount = json['proteinAmount'];
    fatAmount = json['fatAmount'];
    calorieAmount = json['calorieAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unit'] = unit;
    data['type'] = type;
    data['carbohydrateAmount'] = carbohydrateAmount;
    data['proteinAmount'] = proteinAmount;
    data['fatAmount'] = fatAmount;
    data['calorieAmount'] = calorieAmount;
    return data;
  }
}
