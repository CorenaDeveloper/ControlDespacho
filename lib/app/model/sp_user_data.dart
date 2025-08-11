class SPUserData {
  String name = "";
  String icon = "";
  int id = 0;

  SPUserData({required this.name,required this.icon,required this.id});

  SPUserData.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = json['id'];
    }
    if (json['icon'] != null) {
      icon = json['icon'];
    }
    if (json['name'] != null) {
      name = json['name'];
    }
  }
}
