class JsonTestModel {
  final String key;

  JsonTestModel({required this.key});

  factory JsonTestModel.fromJson(Map<String, dynamic> json) {
    return JsonTestModel(key: json["key"]);
  }

  Map<String, dynamic> toJson() {
    return {"key": this.key};
  }
}
