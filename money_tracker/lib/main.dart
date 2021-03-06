import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money_tracker/models/moneyModel.dart';
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

  @override
  void initState() {
    super.initState();
    loadCurrencies();
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
                    child: _projectWidget(),
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

  Widget _projectWidget() {
    return FutureBuilder<List<Money>>(
      future: DBHelper.instance.getMoney(),
      builder: (BuildContext context, AsyncSnapshot<List<Money>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text('loading'),
          );
        }
        Future.delayed(Duration.zero, () async {
          setState(() {
            moneys = snapshot.data!.toList();
          });
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: moneys.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Column(
                children: [
                  Text(moneys[index].tag),
                  Text(moneys[index].amount.toString()),
                  Text(moneys[index].date.toString()),
                  Text(moneys[index].type.toString()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
