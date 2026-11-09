library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/local/database.dart' as drift;
import 'package:j_donuts_app/data/local/daos/home_dao.dart' as drift;
import 'package:j_donuts_app/data/local/daos/member_dao.dart' as drift;
import 'package:j_donuts_app/data/local/daos/rewards_dao.dart' as drift;
import 'package:j_donuts_app/features/product/product_import.dart';

part 'domain/entities/member.dart';
part 'domain/entities/banner.dart';
part 'domain/entities/product_section.dart';
part 'domain/entities/shop.dart';
part 'domain/repositories/home_repository.dart';
part 'domain/repositories/sync_repository.dart';
part 'domain/usecases/get_home_usecase.dart';
part 'data/repositories/home_repository_impl.dart';
part 'presentation/bloc/home_event.dart';
part 'presentation/bloc/home_state.dart';
part 'presentation/bloc/home_bloc.dart';
part 'presentation/widgets/member_header.dart';
part 'presentation/widgets/banner_carousel.dart';
part 'presentation/widgets/product_section_list.dart';
part 'presentation/widgets/nearby_shops_row.dart';
part 'presentation/screens/home_screen.dart';
