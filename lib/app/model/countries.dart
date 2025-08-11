class SPCountries {
  String name = "";
  String dialCode = "";
  String code = "";

  SPCountries({required this.name,required this.dialCode,required this.code,});

  SPCountries.fromJson(Map<String, dynamic> json) {
    if (json['name'] != null) {
      name = json['name'];
    }
    if (json['dial_code'] != null) {
      dialCode = json['dial_code'];
    }
    if (json['code'] != null) {
      code = json['code'];
    }
  }
}
