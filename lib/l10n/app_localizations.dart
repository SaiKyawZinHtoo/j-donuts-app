import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'J Donuts'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to J Donuts'**
  String get onboardingTitle;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get getStartedButton;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginLink;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service & Privacy Policy'**
  String get termsPrivacy;

  /// No description provided for @socialSignInUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'{provider} sign-in is not implemented yet.'**
  String socialSignInUnavailableMessage(String provider);

  /// No description provided for @legalPlaceholderSuffix.
  ///
  /// In en, this message translates to:
  /// **'{doc} placeholder'**
  String legalPlaceholderSuffix(String doc);

  /// No description provided for @phoneScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneScreenTitle;

  /// No description provided for @phoneCountryCode.
  ///
  /// In en, this message translates to:
  /// **'+95'**
  String get phoneCountryCode;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'9xxxxxxxx'**
  String get phoneHint;

  /// No description provided for @phoneNotFoundRegister.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this number. Register instead?'**
  String get phoneNotFoundRegister;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @otpScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpScreenTitle;

  /// No description provided for @otpIncorrectCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code, {attemptsLeft} attempt(s) left.'**
  String otpIncorrectCode(int attemptsLeft);

  /// No description provided for @otpLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please resend the code.'**
  String get otpLocked;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String resendIn(String time);

  /// No description provided for @nameScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your name?'**
  String get nameScreenTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @dobScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'When were you born?'**
  String get dobScreenTitle;

  /// No description provided for @dobMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'MM'**
  String get dobMonthLabel;

  /// No description provided for @dobDayLabel.
  ///
  /// In en, this message translates to:
  /// **'DD'**
  String get dobDayLabel;

  /// No description provided for @dobYearLabel.
  ///
  /// In en, this message translates to:
  /// **'YYYY'**
  String get dobYearLabel;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeTitle;

  /// No description provided for @letsExploreButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s explore'**
  String get letsExploreButton;

  /// No description provided for @homeOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing the last saved data.'**
  String get homeOfflineBanner;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get nothingHereYet;

  /// No description provided for @noNearbyShopsFound.
  ///
  /// In en, this message translates to:
  /// **'No nearby shops found.'**
  String get noNearbyShopsFound;

  /// No description provided for @noBannersRightNow.
  ///
  /// In en, this message translates to:
  /// **'No banners right now.'**
  String get noBannersRightNow;

  /// No description provided for @nearbyShopsTitle.
  ///
  /// In en, this message translates to:
  /// **'There are {count} J\'Donut shops'**
  String nearbyShopsTitle(int count);

  /// No description provided for @memberTierStatus.
  ///
  /// In en, this message translates to:
  /// **'{tier} tier · {points} pts to next tier'**
  String memberTierStatus(String tier, int points);

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @discountBadge.
  ///
  /// In en, this message translates to:
  /// **'-{percent}%'**
  String discountBadge(int percent);

  /// No description provided for @priceMmk.
  ///
  /// In en, this message translates to:
  /// **'{price} MMK'**
  String priceMmk(String price);

  /// No description provided for @productAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productAppBarTitle;

  /// No description provided for @addedToCartMessage.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCartMessage;

  /// No description provided for @whatsThis.
  ///
  /// In en, this message translates to:
  /// **'What\'s this?'**
  String get whatsThis;

  /// No description provided for @addToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to cart · {total} MMK'**
  String addToCartButton(String total);

  /// No description provided for @earnTab.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earnTab;

  /// No description provided for @giftTab.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get giftTab;

  /// No description provided for @homeTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTabLabel;

  /// No description provided for @exploreTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTabLabel;

  /// No description provided for @rewardsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTabLabel;

  /// No description provided for @walletTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTabLabel;

  /// No description provided for @settingsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTabLabel;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{label} coming soon'**
  String comingSoon(String label);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'my':
      return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
