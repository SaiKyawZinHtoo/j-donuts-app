library product;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/local/database.dart' as drift;
import 'package:j_donuts_app/data/local/daos/product_dao.dart' as drift;

part 'domain/entities/product.dart';
part 'domain/repositories/product_repository.dart';
part 'domain/usecases/get_product_usecase.dart';
part 'data/repositories/product_repository_impl.dart';
part 'presentation/hero_tag.dart';
part 'presentation/bloc/product_detail_event.dart';
part 'presentation/bloc/product_detail_state.dart';
part 'presentation/bloc/product_detail_bloc.dart';
part 'presentation/screens/product_detail_screen.dart';
