part of '../../home_import.dart';

/// A physical shop location shown on the home screen.
class Shop {
  final String id;
  final String name;
  final String address;
  final String distanceLabel;

  const Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceLabel,
  });
}
