import 'package:drift/drift.dart';

class Challenges extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text()();
  TextColumn get title => text()();
  IntColumn get current => integer()();
  IntColumn get target => integer()();
  IntColumn get rewardPts => integer()();
  TextColumn get artType => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
