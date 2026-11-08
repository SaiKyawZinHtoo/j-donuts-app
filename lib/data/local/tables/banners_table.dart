import 'package:drift/drift.dart';

class Banners extends Table {
  TextColumn get id => text()();
  TextColumn get imageUrl => text()();
  TextColumn get title => text()();
  TextColumn get deepLinkTarget => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
