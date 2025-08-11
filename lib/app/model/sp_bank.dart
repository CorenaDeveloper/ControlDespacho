class SPBank {
  int id = 0;
  String name = "";
  String icon = "";
  String description = "";

  SPBank.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = json['id'];
    }
    if (json['name'] != null) {
      name = json['name'];
    }
    if (json['icon'] != null) {
      icon = json['icon'];
    }
    if (json['description'] != null) {
      description = json['description'];
    }
  }
}
