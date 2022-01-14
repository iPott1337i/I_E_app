import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money_tracker/models/moneyModel.dart';
import 'package:money_tracker/moneyList.dart';
import 'package:money_tracker/utils/colors.dart';
import 'package:money_tracker/utils/customAppBar.dart';
import 'package:money_tracker/utils/database.dart';
import 'package:money_tracker/utils/money.dart';
import 'package:money_tracker/utils/themedata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addMoney.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // scaffoldBackgroundColor: Palette.darkTurquoise,
        // backgroundColor: Palette.darkTurquoise,
        primarySwatch: Colors.blue,
        textTheme: tTheme,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Money> moneys = [];
  List<String> currencies = [];
  Map currencyMap = {};
  String expenses = "";
  String incomes = "";
  String balance = "";
  @override
  void initState() {
    super.initState();
    loadCurrencies();
    loadEI();
  }

  loadEI() async {
    String exp = await DBHelper.instance.getExpenses();
    String inc = await DBHelper.instance.getIncomes();
    String bal = (double.tryParse(inc)! - double.tryParse(exp)!).toString();
    setState(() {
      expenses = exp;
      incomes = inc;
      balance = bal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        "",
        const SizedBox.shrink(),
        IconButton(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMoney(),
              ),
            ),
          },
          icon: const Icon(
            Icons.add,
            size: 30,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Card(
              elevation: 0,
              child: Column(
                children: [
                  Expanded(
                    child: Text("$expenses | $incomes"),
                  ),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoneyList(),
                            ),
                          ),
                        },
                        child: Text(balance),
                      ),
                    ),
                  ),
                  // FloatingActionButton(
                  //   child: const Text('+'),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => AddMoney()),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
