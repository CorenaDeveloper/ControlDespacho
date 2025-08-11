class SPTransactionHistory {
  String name = "";
  String icon = "";
  String status = "";
  int id = 0;
  double amount = 0;
  DateTime date = DateTime.now();


  SPTransactionHistory.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = json['id'];
    }
    if (json['icon'] != null) {
      icon = json['icon'];
    }
    if (json['name'] != null) {
      name = json['name'];
    }
    if (json['status'] != null) {
      status = json['status'];
    }
    if (json['amount'] != null) {
      amount = json['amount'];
    }
    if (json['date'] != null) {
      date = DateTime.parse(json['date'].toString());
    }
  }
}
