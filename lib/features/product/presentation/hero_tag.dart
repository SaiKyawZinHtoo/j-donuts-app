part of '../product_import.dart';

/// Section-scoped Hero tag: the same product can appear in several Home
/// sections at once, so a product-only tag would duplicate.
String heroTagFor(String sectionId, String productId) => 'product-$sectionId-$productId';
