class PaymentType {
  String name = "";
  String icon = "";
  int id = 0;

  PaymentType({required this.name,required this.icon,required this.id});

  PaymentType.fromJson(Map<String, dynamic> json) {
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
