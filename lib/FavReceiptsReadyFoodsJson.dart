class FavReceiptsReadyFoods {
  int? additionalProp1;
  int? additionalProp2;
  int? additionalProp3;

  FavReceiptsReadyFoods(
      {this.additionalProp1, this.additionalProp2, this.additionalProp3});

  FavReceiptsReadyFoods.fromJson(Map<String, dynamic> json) {
    additionalProp1 = json['additionalProp1'];
    additionalProp2 = json['additionalProp2'];
    additionalProp3 = json['additionalProp3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['additionalProp1'] = additionalProp1;
    data['additionalProp2'] = additionalProp2;
    data['additionalProp3'] = additionalProp3;
    return data;
  }
}
