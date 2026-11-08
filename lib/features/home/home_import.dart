library home;

import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/local/database.dart' as drift;
import 'package:j_donuts_app/data/local/daos/home_dao.dart' as drift;
import 'package:j_donuts_app/data/local/daos/member_dao.dart' as drift;

part 'domain/entities/member.dart';
part 'domain/entities/banner.dart';
part 'domain/entities/product_section.dart';
part 'domain/entities/shop.dart';
part 'domain/repositories/home_repository.dart';
part 'domain/usecases/get_home_usecase.dart';
part 'data/repositories/home_repository_impl.dart';
