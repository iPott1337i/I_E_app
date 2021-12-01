import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_select/smart_select.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class AddMoney extends StatefulWidget {
  AddMoney({Key? key}) : super(key: key);

  @override
  _AddMoneyState createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  //Controller for Inputs
  final amountController = TextEditingController();

  //Variables for later use
  String value = 'test';
  DateTime selectedDate = DateTime.now();
  String date = '';

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
  void initState() {
    // TODO: implement initState
    _updateDateText(selectedDate);
    super.initState();
  }

  _updateDateText(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      date = DateFormat('dd-MM-yyyy').format(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          shrinkWrap: true,
          children: [
            //Button to go back
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('<'),
            ),
            //Input field for money amount
            TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              controller: amountController,
              inputFormatters: [
                DecimalTextInputFormatter(decimalRange: 2),
                ThousandsFormatter(allowFraction: true),
              ],
              decoration: const InputDecoration(
                hintText: 'Wert eingeben',
              ),
            ),
            //tag selection
            SmartSelect<String>.single(
              title: 'Tags',
              value: value,
              choiceItems: tags,
              onChange: (state) => setState(() => value = state.value),
            ),
            //Date picker
            // SfDateRangePicker(),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('$date'),
            ),
          ],
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      _updateDateText(picked);
    }
  }
}

//code to only allow 2 digits after a '.'
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
    return newValue;
  }
}
