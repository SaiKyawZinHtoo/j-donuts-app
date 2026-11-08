import 'package:drift/drift.dart';

/// Single fixed-id row holding the current member's profile + loyalty state.
@DataClassName('MemberData')
class Member extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get photoUrl => text().withDefault(const Constant(''))();
  TextColumn get tier => text()();
  IntColumn get points => integer()();
  IntColumn get nextTierPoints => integer()();
  IntColumn get totalPoints => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
