import 'package:flutter/material.dart';
import 'package:money_tracker/utils/customAppBar.dart';
import 'package:money_tracker/utils/database.dart';

import 'models/moneyModel.dart';
import 'package:intl/intl.dart';

class MoneyList extends StatefulWidget {
  MoneyList({Key? key}) : super(key: key);

  @override
  _MoneyListState createState() => _MoneyListState();
}

class _MoneyListState extends State<MoneyList> {
  List<Money> moneys = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        DateFormat("MM-yyyy").format(DateTime.now()),
        IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        const SizedBox.shrink(),
      ),
      body: _projectWidget(),
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
            return Dismissible(
              key: Key(moneys[index].toString()),
              onDismissed: (direction) {
                DBHelper.instance.deleteMoney(moneys[index].id!);
                setState(() {
                  moneys.removeAt(index);
                });
              },
              child: ListTile(
                leading: (moneys[index].type == 1)
                    ? const Icon(Icons.add)
                    : const Icon(Icons.minimize),
                title: Text(moneys[index].tag),
                subtitle: Text(
                    "${moneys[index].amount.toString()} | ${moneys[index].date.toString()}"),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
