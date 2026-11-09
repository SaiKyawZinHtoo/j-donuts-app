library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoDatePicker,
        CupertinoDatePickerMode,
        showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

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
part 'presentation/bloc/auth_event.dart';
part 'presentation/bloc/auth_state.dart';
part 'presentation/bloc/auth_bloc.dart';
part 'presentation/widgets/registration_progress_ring.dart';
part 'presentation/widgets/donut_tile.dart';
part 'presentation/widgets/onboarding_tiles.dart';
part 'presentation/widgets/onboarding_art.dart';
part 'presentation/screens/onboarding_screen.dart';
part 'presentation/screens/phone_screen.dart';
part 'presentation/screens/otp_screen.dart';
part 'presentation/screens/name_screen.dart';
part 'presentation/screens/dob_screen.dart';
part 'presentation/screens/welcome_screen.dart';
