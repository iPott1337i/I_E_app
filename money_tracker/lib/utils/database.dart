import 'dart:io';

import 'package:money_tracker/models/moneyModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ?? await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'experiments.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bank(
        id INTEGER PRIMARY KEY,
        type NUMBER(1),
        amount DOUBLE,
        date DATE,
        tag TEXT
      );
    ''');
  }

  Future saveMoney(Money money) async {
    Database db = await instance.database;
    await db.transaction((txn) async {
      txn.insert('bank', money.toMap());
    });
  }

  Future<List<Money>> getMoney() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM bank ORDER BY id ASC');
    List<Money> moneys = [];
    for (var element in list) {
      moneys.add(
        Money(
          id: element['id'],
          type: element['type'],
          amount: element['amount'],
          date: element['date'],
          tag: element['tag'],
        ),
      );
    }
    return moneys;
  }
}
