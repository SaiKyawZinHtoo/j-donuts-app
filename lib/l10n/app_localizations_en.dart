// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'J Donuts';

  @override
  String get onboardingTitle => 'Welcome to J Donuts';

  @override
  String get getStartedButton => 'Let\'s get started';

  @override
  String get loginLink => 'Log in';

  @override
  String get termsPrivacy => 'Terms of Service & Privacy Policy';

  @override
  String socialSignInUnavailableMessage(String provider) {
    return '$provider sign-in is not implemented yet.';
  }

  @override
  String legalPlaceholderSuffix(String doc) {
    return '$doc placeholder';
  }

  @override
  String get phoneScreenTitle => 'Enter your phone number';

  @override
  String get phoneCountryCode => '+95';

  @override
  String get phoneHint => '9xxxxxxxx';

  @override
  String get phoneNotFoundRegister =>
      'We couldn\'t find this number. Register instead?';

  @override
  String get continueButton => 'Continue';

  @override
  String get otpScreenTitle => 'Enter the 6-digit code';

  @override
  String otpIncorrectCode(int attemptsLeft) {
    return 'Incorrect code, $attemptsLeft attempt(s) left.';
  }

  @override
  String get otpLocked => 'Too many attempts. Please resend the code.';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get nameScreenTitle => 'What is your name?';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get dobScreenTitle => 'When were you born?';

  @override
  String get dobMonthLabel => 'MM';

  @override
  String get dobDayLabel => 'DD';

  @override
  String get dobYearLabel => 'YYYY';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get letsExploreButton => 'Let\'s explore';

  @override
  String get homeOfflineBanner =>
      'You\'re offline. Showing the last saved data.';

  @override
  String get nothingHereYet => 'Nothing here yet.';

  @override
  String get noNearbyShopsFound => 'No nearby shops found.';

  @override
  String get noBannersRightNow => 'No banners right now.';

  @override
  String nearbyShopsTitle(int count) {
    return 'There are $count J\'Donut shops';
  }

  @override
  String memberTierStatus(String tier, int points) {
    return '$tier tier · $points pts to next tier';
  }

  @override
  String get newBadge => 'New';

  @override
  String discountBadge(int percent) {
    return '-$percent%';
  }

  @override
  String priceMmk(String price) {
    return '$price MMK';
  }

  @override
  String get productAppBarTitle => 'Product';

  @override
  String get addedToCartMessage => 'Added to cart';

  @override
  String get whatsThis => 'What\'s this?';

  @override
  String addToCartButton(String total) {
    return 'Add to cart · $total MMK';
  }

  @override
  String get earnTab => 'Earn';

  @override
  String get giftTab => 'Gift';

  @override
  String get homeTabLabel => 'Home';

  @override
  String get exploreTabLabel => 'Explore';

  @override
  String get rewardsTabLabel => 'Rewards';

  @override
  String get walletTabLabel => 'Wallet';

  @override
  String get settingsTabLabel => 'Settings';

  @override
  String comingSoon(String label) {
    return '$label coming soon';
  }

  @override
  String get logOut => 'Log out';
}
