class SPCards {
  String cardHolderName = '';
  String bankName = '';
  bool isWifiAvailable = false;
  String cardNumber = '';
  String cardBgImage = '';

  SPCards.fromJson(Map<String, dynamic> json) {
    if (json['card_holder_name'] != null) {
      cardHolderName = json['card_holder_name'];
    }
    if (json['bank_name'] != null) {
      bankName = json['bank_name'];
    }
    if (json['is_wifi_available'] != null) {
      isWifiAvailable = json['is_wifi_available'];
    }
    if (json['card_number'] != null) {
      cardNumber = json['card_number'];
    }
    if (json['card_bg_image'] != null) {
      cardBgImage = json['card_bg_image'];
    }
  }
}
