// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dao.dart';

// ignore_for_file: type=lint
mixin _$HomeDaoMixin on DatabaseAccessor<AppDatabase> {
  $MemberTable get member => attachedDatabase.member;
  $BannersTable get banners => attachedDatabase.banners;
  $SectionsTable get sections => attachedDatabase.sections;
  $SectionsProductsTable get sectionsProducts =>
      attachedDatabase.sectionsProducts;
  $ProductsTable get products => attachedDatabase.products;
  $ShopsTable get shops => attachedDatabase.shops;
  HomeDaoManager get managers => HomeDaoManager(this);
}

class HomeDaoManager {
  final _$HomeDaoMixin _db;
  HomeDaoManager(this._db);
  $$MemberTableTableManager get member =>
      $$MemberTableTableManager(_db.attachedDatabase, _db.member);
  $$BannersTableTableManager get banners =>
      $$BannersTableTableManager(_db.attachedDatabase, _db.banners);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$SectionsProductsTableTableManager get sectionsProducts =>
      $$SectionsProductsTableTableManager(
        _db.attachedDatabase,
        _db.sectionsProducts,
      );
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$ShopsTableTableManager get shops =>
      $$ShopsTableTableManager(_db.attachedDatabase, _db.shops);
}
