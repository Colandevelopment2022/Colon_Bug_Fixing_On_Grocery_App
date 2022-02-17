class LocateMeResponse {
  String attributeCode;
  String value;

  LocateMeResponse({this.attributeCode, this.value});

  LocateMeResponse.fromJson(Map<String, dynamic> json) {
    attributeCode = json['attribute_code'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attribute_code'] = this.attributeCode;
    data['value'] = this.value;
    return data;
  }
}
