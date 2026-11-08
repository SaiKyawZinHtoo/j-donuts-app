library auth;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/local/daos/auth_dao.dart';
import 'package:j_donuts_app/data/local/database.dart' as drift;

part 'domain/validators/validation_result.dart';
part 'domain/validators/phone_validator.dart';
part 'domain/validators/otp_validator.dart';
part 'domain/validators/name_validator.dart';
part 'domain/validators/dob_validator.dart';
part 'domain/entities/auth_user.dart';
part 'domain/repositories/auth_repository.dart';
part 'domain/usecases/login_usecase.dart';
part 'domain/usecases/register_usecase.dart';
part 'domain/usecases/get_session_usecase.dart';
part 'data/datasources/session_datasource.dart';
part 'data/datasources/auth_local_datasource.dart';
part 'data/repositories/auth_repository_impl.dart';
