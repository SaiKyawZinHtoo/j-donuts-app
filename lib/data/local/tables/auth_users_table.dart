import 'package:drift/drift.dart';

class AuthUsers extends Table {
  TextColumn get id => text()();
  TextColumn get phone => text().unique()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  DateTimeColumn get dob => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
