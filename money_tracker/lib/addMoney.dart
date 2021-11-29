import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_select/smart_select.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class AddMoney extends StatefulWidget {
  AddMoney({Key? key}) : super(key: key);

  @override
  _AddMoneyState createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  //Controller for Inputs
  final amountController = TextEditingController();
  String value = 'test';

  //Tag-Options (Soon: more languages supported)
  List<S2Choice<String>> tags = [
    S2Choice<String>(value: 'shopping', title: 'Shopping'),
    S2Choice<String>(value: 'goOut', title: 'Going Out'),
    S2Choice<String>(value: 'entertainment', title: 'Entertainment'),
    S2Choice<String>(value: 'eat', title: 'Eating / Drinking'),
    S2Choice<String>(value: 'journey', title: 'Journey'),
    S2Choice<String>(value: 'gifts', title: 'Gifts'),
    S2Choice<String>(value: 'handy', title: 'Handy'),
    S2Choice<String>(value: 'hobby', title: 'Hobby'),
    S2Choice<String>(value: 'clothes', title: 'Clothes'),
    S2Choice<String>(value: 'rent', title: 'Rent'),
    S2Choice<String>(value: 'other', title: 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          shrinkWrap: true,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('<'),
            ),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              controller: amountController,
              inputFormatters: [
                // CurrencyTextInputFormatter(),
                ThousandsSeparatorInputFormatter(),
                // NumberInputFormatter.currency()
                // ThousandsFormatter(allowFraction: false),
                // FilteringTextInputFormatter.allow(
                // RegExp(r'^\d*\.?\d{0,2}'),
                // ),
              ],
              decoration: const InputDecoration(
                hintText: 'Wert eingeben',
              ),
            ),
            SmartSelect<String>.single(
              title: 'Tags',
              value: value,
              choiceItems: tags,
              onChange: (state) => setState(() => value = state.value),
            ),
          ],
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ','; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1)
          newString = separator + newString;
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}
