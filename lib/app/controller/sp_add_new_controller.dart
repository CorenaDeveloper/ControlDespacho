import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/sp_images.dart';
import '../model/sp_credit_card.dart';

class SpAddNewController extends GetxController {
  final cardHolderNameFieldFocused = false.obs;
  final cardNumberFocused = false.obs;
  final cvvFieldFocused = false.obs;
  final expiryDateFieldFocused = false.obs;

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  FocusNode f5 = FocusNode();
  final formKey = GlobalKey<FormState>();
  TextEditingController cardHolderNameController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardTypeController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();

  final RxList<CardType> cardTypes = [
    CardType(name: 'MasterCard', assetPath: masterCardIcon),
    CardType(name: 'Visa', assetPath: visaIcon),
  ].obs;

  var selectedCardType =
      Rx<CardType>(CardType(name: 'MasterCard', assetPath: masterCardIcon));
  RxString errCardType = ''.obs;

  void setSelectedCardType(CardType cardType) {
    selectedCardType.value = cardType;
  }

  String? validateCreditCard(String text) {
    if (text.isEmpty) {
      return 'Card number is required';
    }
    if (!isValidCreditCardNumber(text)) {
      return 'Invalid card number';
    }
    return null;
  }

  bool isValidCreditCardNumber(String input) {
    input = input.replaceAll(' ', '');
    if (!_hasValidFormat(input)) {
      return false;
    } else {
      return true;
    }

    // return _passesLuhnAlgorithm(input);
  }

  bool _hasValidFormat(String input) {
    // Regular expression to check if the input has a valid credit card number format
    final regex = RegExp(r'^[0-9]{16}$');
    return regex.hasMatch(input);
  }

  @override
  void onInit() {
    super.onInit();
    cardHolderNameController.text = 'Leslie Alexander';
    cardNumberController.text = '4032  8739  0081  6621';
    expiryDateController.text = '12/28';
    cvvController.text = '342';
  }
}
