//Money class

class Money {
  late final int? id;
  int type; //Expense = 0, Income = 1
  double amount;
  DateTime date;
  String tag;

  Money(
      {this.id,
      required this.type,
      required this.amount,
      required this.date,
      required this.tag});

  fromMap(Map map) {
    id = map[id];
    type = map[type];
    amount = map[amount];
    date = map[date];
    tag = map[tag];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date,
      'tag': tag,
    };
  }
}
