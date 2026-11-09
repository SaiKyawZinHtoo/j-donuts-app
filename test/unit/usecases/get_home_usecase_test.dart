import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/product/product_import.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  test(
    'GetHomeUseCase returns Ok with member, banners, sections, shops',
    () async {
      final repo = MockHomeRepository();
      final testBundle = HomeBundle(
        member: const Member(
          id: 'm1',
          name: 'Shan',
          photoUrl: '',
          tier: 'Silver',
          points: 0,
          nextTierPoints: 500,
          totalPoints: 0,
        ),
        banners: const [
          BannerItem(
            id: 'b1',
            imageUrl: 'img.png',
            title: 'Banner',
            deepLinkTarget: '',
          ),
        ],
        sections: const [
          ProductSection(
            id: 's1',
            title: 'Favorites',
            products: [
              Product(
                id: 'p1',
                code: 'DN-001',
                name: 'Glazed',
                priceMmk: 1000,
                isNew: false,
                discountPercent: 0,
                imageUrl: 'img.png',
                description: '',
              ),
            ],
          ),
        ],
        shops: const [
          Shop(
            id: 'sh1',
            name: 'J Donuts',
            address: 'Yangon',
            distanceLabel: '',
          ),
        ],
      );
      when(() => repo.getHome()).thenAnswer((_) async => Result.ok(testBundle));

      final result = await GetHomeUseCase(repo).call();

      expect(result, isA<Ok<HomeBundle>>());
    },
  );
}
