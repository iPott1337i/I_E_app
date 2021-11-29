import 'package:flutter/material.dart';
import 'package:money_tracker/models/moneyModel.dart';
import 'package:money_tracker/utils/database.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          shrinkWrap: true,
          children: [
            _projectWidget(),
            FloatingActionButton(
                child: const Text('+'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddMoney()),
                  );
                }),
          ],
        ),
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
