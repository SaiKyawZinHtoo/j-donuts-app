/// Named constants for the JSON keys used in assets/seed/*.json, so the
/// seed loader never relies on magic strings.
library;

class SeedKeys {
  // meta
  static const seededFlagKey = 'seeded';
  // Bump when assets/seed/*.json change so existing installs reseed.
  static const seedVersion = '2';

  // products.json
  static const id = 'id';
  static const code = 'code';
  static const name = 'name';
  static const priceMmk = 'priceMmk';
  static const isNew = 'isNew';
  static const discountPercent = 'discountPercent';
  static const imageUrl = 'imageUrl';
  static const description = 'description';

  // banners.json
  static const title = 'title';
  static const deepLinkTarget = 'deepLinkTarget';

  // sections.json
  static const productIds = 'productIds';

  // shops.json
  static const address = 'address';
  static const distanceLabel = 'distanceLabel';

  // member.json
  static const photoUrl = 'photoUrl';
  static const tier = 'tier';
  static const points = 'points';
  static const nextTierPoints = 'nextTierPoints';
  static const totalPoints = 'totalPoints';
  static const challenges = 'challenges';
  static const memberId = 'memberId';
  static const current = 'current';
  static const target = 'target';
  static const rewardPts = 'rewardPts';
  static const artType = 'artType';
}
