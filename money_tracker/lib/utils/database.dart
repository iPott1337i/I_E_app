import 'dart:io';

import 'package:money_tracker/models/moneyModel.dart';
import 'package:money_tracker/utils/money.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    //table for all the expenses and income
    await db.execute('''
      CREATE TABLE bank(
        id INTEGER PRIMARY KEY,
        type NUMBER(1),
        amount DOUBLE,
        date TEXT,
        tag TEXT
      );
    ''');

    //db 'exc' (exchange currency values based on 'EUR' will be stored in here)
    await db.execute('''
      CREATE TABLE exc(
        id INTEGER PRIMARY KEY,
        json TEXT
      );
    ''');
    //get first exc (hope for internet connectivity lol)
    Map firstExc = await getCurrentExcFromApi();
    db.rawInsert('''
      INSERT INTO exc (id, json)
      VALUES (null, ?);
    ''', [json.encode(firstExc)]);
  }

  Future getFirstExc() async {
    Database db = await instance.database;
    Map firstExc = await getCurrentExcFromApi();
    db.rawInsert('''
      INSERT INTO exc (id, json)
      VALUES (null, ?);
    ''', [json.encode(firstExc)]);
  }

  Future getCurrentExc() async {
    Database db = await instance.database;
    var result = await db.rawQuery('SELECT * FROM exc LIMIT 1');
    var json2 = result[0]['json'];
    return json.decode(json2.toString());
  }

  Future updateExc(Map newExc) async {
    Database db = await instance.database;

    db.rawUpdate('''
        UPDATE exc
        SET json = ?
        WHERE id = 1
      ''', [json.encode(newExc)]);
  }

  Future saveMoney(Money money) async {
    Database db = await instance.database;
    await db.transaction((txn) async {
      txn.insert('bank', money.toMap());
    });
  }

  Future<List<Money>> getMoney() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM bank ORDER BY date DESC');
    //WHERE date >= "2022-01-01" AND date <= "2022-01-31"
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

  Future<String> getExpenses() async {
    Database db = await instance.database;
    List<Map<String, Object?>> expenses = await db.rawQuery(
        'SELECT SUM(amount) AS "exp" FROM bank  WHERE type = "0" AND date >= "2022-01-01" AND date <= "2022-01-31"');
    return expenses[0]["exp"].toString();
  }

  Future<String> getIncomes() async {
    Database db = await instance.database;
    List<Map<String, Object?>> incomes = await db.rawQuery(
        'SELECT SUM(amount) AS "inc" FROM bank  WHERE type = "1" AND date >= "2022-01-01" AND date <= "2022-01-31"');
    return incomes[0]["inc"].toString();
  }

  Future deleteMoney(int id) async {
    Database db = await instance.database;
    db.rawDelete('DELETE FROM bank WHERE id = ?', [id]);
  }
}
