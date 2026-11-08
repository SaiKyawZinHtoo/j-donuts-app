import 'package:drift/drift.dart';

class Sections extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class SectionsProducts extends Table {
  TextColumn get sectionId => text()();
  TextColumn get productId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {sectionId, productId};
}
