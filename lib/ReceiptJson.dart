import 'package:colyakapp/NutritionalValuesList.dart';

class ReceiptJson {
  int? id;
  String? receiptName;
  String? createdDate;
  List<String>? receiptDetails;
  List<ReceiptItems>? receiptItems;
  List<NutritionalValuesList>? nutritionalValuesList;
  int? imageId;
  bool? deleted;

  ReceiptJson(
      {this.id,
      this.receiptName,
      this.createdDate,
      this.receiptDetails,
      this.receiptItems,
      this.nutritionalValuesList,
      this.imageId,
      this.deleted});

  ReceiptJson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    receiptName = json['receiptName'];
    createdDate = json['createdDate'];
    receiptDetails = json['receiptDetails'].cast<String>();
    if (json['receiptItems'] != null) {
      receiptItems = <ReceiptItems>[];
      json['receiptItems'].forEach((v) {
        receiptItems!.add(ReceiptItems.fromJson(v));
      });
    }
    if (json['nutritionalValuesList'] != null) {
      nutritionalValuesList = <NutritionalValuesList>[];
      json['nutritionalValuesList'].forEach((v) {
        nutritionalValuesList!.add(NutritionalValuesList.fromJson(v));
      });
    }
    imageId = json['imageId'];
    deleted = json['deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['receiptName'] = receiptName;
    data['createdDate'] = createdDate;
    data['receiptDetails'] = receiptDetails;
    if (receiptItems != null) {
      data['receiptItems'] = receiptItems!.map((v) => v.toJson()).toList();
    }
    if (nutritionalValuesList != null) {
      data['nutritionalValuesList'] =
          nutritionalValuesList!.map((v) => v.toJson()).toList();
    }
    data['imageId'] = imageId;
    data['deleted'] = deleted;
    return data;
  }
}

class ReceiptItems {
  int? id;
  String? productName;
  double? unit;
  String? type;

  ReceiptItems({this.id, this.productName, this.unit, this.type});

  ReceiptItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['productName'];
    unit = json['unit'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productName'] = productName;
    data['unit'] = unit;
    data['type'] = type;
    return data;
  }
}