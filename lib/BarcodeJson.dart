import 'package:colyakapp/ReceiptJson.dart';

class BarcodeJson {
  int? id;
  int? code;
  String? name;
  int? imageId;
  bool? glutenFree;
  bool? deleted;
  List<NutritionalValuesList>? nutritionalValuesList;

  BarcodeJson(
      {this.id,
      this.code,
      this.name,
      this.imageId,
      this.glutenFree,
      this.deleted,
      this.nutritionalValuesList});

  BarcodeJson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    imageId = json['imageId'];
    glutenFree = json['glutenFree'];
    deleted = json['deleted'];
    if (json['nutritionalValuesList'] != null) {
      nutritionalValuesList = <NutritionalValuesList>[];
      json['nutritionalValuesList'].forEach((v) {
        nutritionalValuesList!.add(NutritionalValuesList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['imageId'] = imageId;
    data['glutenFree'] = glutenFree;
    data['deleted'] = deleted;
    if (nutritionalValuesList != null) {
      data['nutritionalValuesList'] =
          nutritionalValuesList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
