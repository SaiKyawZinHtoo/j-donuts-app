import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoTextThemeData, CupertinoThemeData;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'package:j_donuts_app/l10n/app_localizations.dart';

export 'package:j_donuts_app/l10n/app_localizations.dart';

part 'theme/colors.dart';
part 'theme/app_fonts.dart';
part 'theme/text_styles.dart';
part 'theme/spacing.dart';
part 'theme/motion_tokens.dart';
part 'theme/app_theme.dart';
part 'constants/app_constants.dart';
part 'constants/app_assets.dart';
part 'widgets/app_text_field.dart';
part 'widgets/app_button.dart';
part 'widgets/app_otp_box.dart';
part 'widgets/app_progress_ring.dart';
part 'widgets/app_skeleton.dart';
part 'widgets/app_empty_state.dart';
part 'widgets/app_error_state.dart';
part 'widgets/app_dialog.dart';
part 'widgets/app_snackbar.dart';
part 'widgets/app_app_bar.dart';
part 'widgets/app_bottom_nav.dart';
part 'widgets/app_smart_image.dart';
part 'widgets/app_legal_footer.dart';
part 'widgets/app_gradient_background.dart';
part 'widgets/social_sign_in_button.dart';
part 'widgets/app_back_button.dart';
part 'widgets/auth_scaffold.dart';
part 'widgets/product_card.dart';
part 'widgets/section_header.dart';
part 'services/connectivity_service.dart';
part 'services/fake_sms_notifier.dart';
