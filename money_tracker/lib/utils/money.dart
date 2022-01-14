import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'database.dart';

Future<bool> isConnected() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      return true;
    }
  } on SocketException catch (_) {
    print(false);
    return false;
  }
  return false;
}

Future<Map> getCurrentExcFromApi() async {
  String uri =
      "http://api.exchangeratesapi.io/v1/latest?access_key=94cf62ea0f5ec5f2aec8a071dab44f15&format=1&symbols=USD,GBP,CRC";
  var response = await http.get(Uri.parse(uri));
  var responseBody = json.decode(response.body);
  return responseBody;
}

//function for api calls for the currencies
loadCurrencies() async {
  String currDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Map curExc = await DBHelper.instance.getCurrentExc();

  if (currDate.compareTo(curExc['date']) == 1) {
    if (await isConnected()) {
      Map newExc = await getCurrentExcFromApi();
      DBHelper.instance.updateExc(newExc);
      print(1);
      print(newExc);
      return newExc;
    }
  }
  print(currDate.compareTo(curExc['date']));
  print(0);
  print(curExc);
  return curExc;
}
