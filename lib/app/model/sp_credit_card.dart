class SPCreditCard {
  String iconName;
  String cardName;
  String cardNumber;

  SPCreditCard(
      {required this.iconName,
      required this.cardName,
      required this.cardNumber});
}

class CardType {
  final String name;
  final String assetPath;

  CardType({required this.name, required this.assetPath});
}
