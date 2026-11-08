import 'package:drift/drift.dart';

class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get distanceLabel => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
