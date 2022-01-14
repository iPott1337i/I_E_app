import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_tracker/models/moneyModel.dart';
import 'package:money_tracker/utils/colors.dart';
import 'package:money_tracker/utils/customAppBar.dart';
import 'package:money_tracker/utils/database.dart';
import 'package:smart_select/smart_select.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:sqflite/sqlite_api.dart';

class AddMoney extends StatefulWidget {
  AddMoney({Key? key}) : super(key: key);

  @override
  _AddMoneyState createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  //Controller for Inputs
  final amountController = TextEditingController();

  //Variables for later use
  String tag = 'test'; // tag
  DateTime selectedDate = DateTime.now();
  String date = '';
  bool e_i = false; //false = expense, true = income
  String currency = 'EUR';

  double finalValue = 0;

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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Palette.darkTurquoise,
              Palette.languidLavender,
            ],
          ),
        ),
        child: Scaffold(
          appBar: CustomAppBar(
            "Add",
            IconButton(
              onPressed: () => {Navigator.pop(context)},
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
            const SizedBox.shrink(),
          ),
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              _addMoney(),
              const Spacer(),
            ],
          ),
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

  _addMoney<Widget>() {
    return Card(
      // decoration: BoxDecoration(gradient: ),
      elevation: 7,
      color: Colors.white,
      // e_i ? Palette.yellowGreenCrayola : Palette.lightFieryRose,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: !e_i ? Palette.fieryRose : Palette.yellowGreenCrayola,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            //Expense or Income option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Expense',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Palette.fieryRose,
                  ),
                ),
                Switch(
                  activeColor: Palette.yellowGreenCrayola,
                  inactiveThumbColor: Palette.fieryRose,
                  inactiveTrackColor: Palette.fieryRose,
                  value: e_i,
                  onChanged: (bool value) {
                    setState(() {
                      e_i = value;
                    });
                  },
                ),
                Text(
                  'Income',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Palette.yellowGreenCrayola,
                  ),
                ),
              ],
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
            //Currency
            DropdownButton(
              dropdownColor: Colors.white,
              value: currency,
              items: <String>['EUR', 'USD', 'CRC'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  currency = newValue!;
                  print(currency);
                });
              },
            ),
            //tag selection
            SmartSelect<String>.single(
              title: 'Tags',
              modalStyle: const S2ModalStyle(
                backgroundColor: Colors.white,
              ),
              modalHeaderStyle: const S2ModalHeaderStyle(
                backgroundColor: Colors.white,
              ),
              value: tag,
              choiceItems: tags,
              onChange: (state) => setState(() => tag = state.value),
            ),
            //Date picker
            // SfDateRangePicker(),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(date),
            ),
            ElevatedButton(
              onPressed: _validate() ? _submitForm : null,
              child: const Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    //calculate the real value depending on the selected currency
    finalValue = await _calculateCurrency();
    print(finalValue);
    Money money = Money(
      type: e_i ? 1 : 0,
      amount: finalValue,
      date: DateFormat('yyyy-MM-dd').format(selectedDate),
      tag: tag,
    );
    DBHelper.instance.saveMoney(money);

    //setting back the default values
    // setState(() {
    //   amountController.clear();
    //   _updateDateText(DateTime.now()); //?
    //   tag = 'test';
    //   currency = 'EUR';
    //   e_i = false;
    // });
    Navigator.pop(context);
  }

  _validate<bool>() {
    if (amountController.text == "" || tag == 'test') {
      return false;
    } else {
      return true;
    }
  }

  _calculateCurrency() async {
    finalValue = double.parse(amountController.text.replaceAll(',', ''));
    Map currencies = await DBHelper.instance.getCurrentExc();

    print(currency);
    print(currencies);
    if (currency != 'EUR') {
      //calculate the new value if currency isn't 'EUR' by dividing through value and round on 2 decimal places
      double newValue = (finalValue / currencies['rates'][currency]);
      print(newValue);
      newValue =
          ((newValue * math.pow(10.0, 2)).roundToDouble() / math.pow(10.0, 2));
      // double.parse(newValue.toStringAsFixed(2));
      print(newValue);
      return newValue;
    }
    return finalValue;
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
  }
}
