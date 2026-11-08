# Home / Product detail / Bottom nav / Welcome fidelity — design

Date: 2026-11-09. Follows `2026-11-08-ui-overhaul-design.md`, which left Home, Product and Rewards restyling out of scope because the reference set then showed only the auth screens. New references (screens 7 Welcome, 8 Home, 9 Product detail, and a circled bottom nav) reverse that for Home, Product detail, nav and Welcome.

## Goal

Home, Product detail, the bottom nav and Welcome look and move like the references. All product cards share one widget. Motion follows the PDF motion table and honors Reduce Motion.

## Decisions already made with the user

- One shared `ProductCard` with two image modes (not two card widgets).
- "explore screen" means Welcome (reference 7).
- Bell count "2" is a static seed value; no notification feature.
- Sky/cloud/grass backdrop is a bundled image, not drawn in code.
- Photos come from jdonuts.com, downloaded once and bundled locally (same method as the previous overhaul: `/_next/image` proxy).

## Global constraints (carried over)

DRY; shared widgets in `lib/core/widgets`; tokens, not literals (`AppColors`, `AppSpacing`, `MotionTokens`); part-of-barrel convention (part files carry no imports); standard Material/Cupertino icons; every animation honors `MediaQuery.disableAnimationsOf`; Hero tags are section-scoped via `heroTagFor(sectionId, productId)`; `/product/:id` stays a `CupertinoPage` (its push/pop timing is the documented Reduce Motion exception); `flutter analyze` must not grow beyond the 11 existing infos; all existing tests keep passing or are updated deliberately.

## 1. Foundation

- **`ProductCard`** (`lib/core/widgets/product_card.dart`, part of `core_import.dart`). Inputs: image URL, title (max 2 lines), optional badge, `ProductCardImageMode { photo, cutout }`, `heroTag`, `onTap`. Same corner radius, title block and pill in both modes.
  - `photo`: image fills a rounded rectangle; title below on the page background.
  - `cutout`: white rounded card, donut centered with soft shadow; title below.
  - Pill: orange (`AppColors.badge`, new token) rounded pill, white bold text, bottom-right of the image. "New" wins over a discount, as today; discount renders as "N% off".
  - Press feedback: scale 0.97 via the same `Listener` approach as `AppButton`.
- **Tokens:** `AppColors.badge` (orange sampled from reference), `AppColors.pageGrey` (reference 8/9 grey page), `AppColors.headerPeach`, `AppColors.navBar` reuses `primary`. `AppSpacing`: `cardRadius`, `sectionGap`, `headerRadius`, `qtyPillHeight`. `MotionTokens`: `kProductCardEntrance`, `kQtyChange` (150ms), `kDescriptionExpand` (250ms), `kDetailEntrance` (400ms).
- **Section header** widget (`SectionHeader`: title + white circular chevron button) in core, used by every Home section.
- **Assets:** seasonal box photos (2), shop photos (2), banner artwork (purple "New shop", cyan "Hot…"), member avatar, sky/cloud/grass backdrop, plus donut cutouts already present. All under `assets/images/seed/`, registered already by the directory entry.

## 2. Home

Structure (top to bottom), all inside the existing `HomeScreen` scroll view and `_SectionEntrance` stagger:

1. **Header** (`MemberHeader`, reworked): peach background with rounded bottom corners (`headerRadius`); avatar with an orange arc; name (h1) and "Bronze member"; white points chip ("N points left to become Gold Member"); grey hexagon star badge top-right; orange bell pill with count at the right edge.
2. **Banner carousel** (`BannerCarousel`, restyled): cards overlap the header's bottom edge; purple and cyan banners with "New shop" / "50% off" pills; autoplay and dots unchanged.
3. **Sections** (`ProductSectionList`, rewritten on `ProductCard`): `SectionHeader` plus a horizontal list. Seasonal specials use `photo` mode (wide card, about 320 logical px); Popular and Order again use `cutout` mode (about 215 px wide). Fixed list height replaced by a height derived from card width and `MediaQuery.textScalerOf`, removing the existing 140px shortcut.
4. **Shops block** (`NearbyShopsRow`, restyled): sky/cloud/grass backdrop, "There are N J'Donut shops near you." heading, "EXPLORE NOW" pill button (existing "not implemented" snackbar), horizontal shop cards (photo, name, address, pink "Order Online").
5. Page background `pageGrey`. Bottom padding equals nav height so content is not hidden behind the floating nav.

Hero from a card image to the detail image is preserved for both modes.

## 3. Bottom nav

`AppBottomNav` keeps the sliding pill and its API. Changes: bar floats over content (Home body extends behind it via `extendBody`), pink pill with white icon and label for the active item, icon set Home, Rewards (crown), Explore-style center icon, Wallet, Settings as in the circled reference, inactive icons white. Tab order and routes unchanged. Reduce Motion: pill jumps.

## 4. Product detail

- Scaffold on `pageGrey`; transparent app bar with plain back arrow (no ring).
- White rounded card: product code (caption, grey), name (h1), price (bold), "New" pill top-right; large donut image centered, tagged with the Hero.
- Quantity pill: white pill with cyan circular − and + buttons and the count between them, centered on the card's bottom edge (half overlapping). Keys `quantityDecrement` / `quantityIncrement` stay.
- Description row: green "?" icon with "What's this?" at left, vertical divider, description at right limited to four lines with a bottom fade; tap expands via `AnimatedSize`.
- Bottom: "ADD TO CART | 3,200 MMK" pill button with a divider between label and total (`addToCartButton` key stays; text format stays compatible with the existing test or the test is updated in the same task).
- Motion: card fades and rises on entry (`kDetailEntrance`); Hero flight from the list; count and total change via `AnimatedSwitcher` (`kQtyChange`); description `AnimatedSize` (`kDescriptionExpand`); button uses existing `AppButton` press scale and loading morph. All gated by Reduce Motion.

## 5. Welcome

Match reference 7: two staggered columns of rounded tiles (existing `DonutTile`), cropped at the screen edges, a white-to-pink fade over the lower tiles, centered title "Welcome to the world of J'donuts", cyan pill "LET'S EXPLORE" pinned above the bottom. Tile drift-in and the existing Welcome layout rules (no `Spacer`/`Expanded` inside `AuthScaffold`'s child) stay.

## Testing

- New `test/widget/core/product_card_test.dart`: both modes render title and image; "New" pill beats discount; discount text "N% off"; tap callback; text scale 1.3 does not overflow.
- Update `home_screen_test.dart` and `home_stagger_hero_test.dart` for the new structure; assert Hero tags stay unique when one product appears in two sections.
- Update `product_detail_screen_test.dart`: total updates on quantity change; description expands; Reduce Motion path.
- Update `app_bottom_nav_test.dart` for the icon set and pill position.
- Welcome test: tiles and button present, no overflow at 375x667 and 430x932.
- Reduce Motion test coverage extended to the new entrance and count animations.
- Final check: simulator walkthrough of Welcome, Home (scroll to end), Product detail, nav, on iPhone 16 Plus.

## Out of scope

Rewards screen restyling, real notifications, real shop data, a hi-res logo, Burmese copy beyond existing ARB keys (new strings are added to both `en` and `my` ARB files).

## Risks

- Photo and backdrop art pulled from jdonuts.com may not exactly match the reference crop; cost is a visual tweak pass.
- Floating nav over scrolling content can hide the last item if bottom padding is wrong; covered by a Home test at the end of scroll.
