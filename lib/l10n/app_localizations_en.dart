// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'J\'Donuts';

  @override
  String get onboardingTitle => 'Round food for every mood';

  @override
  String get getStartedButton => 'Let\'s get started';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginLink => 'Log In';

  @override
  String get termsPrivacyNotice =>
      'By continuing, you acknowledge that you have read and agree to our Terms of Use and Privacy Policy.';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

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
  String get loginScreenTitle => 'Welcome back, Login to your profile';

  @override
  String get loginButton => 'Login';

  @override
  String get otpScreenTitle => 'Verify your number';

  @override
  String otpSubtitle(String phone) {
    return 'We\'ve sent 6 digit OTP to $phone';
  }

  @override
  String otpIncorrectCode(int attemptsLeft) {
    return 'Incorrect code, $attemptsLeft attempt(s) left.';
  }

  @override
  String get otpLocked => 'Too many attempts. Please resend the code.';

  @override
  String get didntReceiveCode => 'Didn\'t receive the code?';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(String time) {
    return 'resend in $time';
  }

  @override
  String get nameScreenTitle => 'What\'s your name?';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get lastNameLabel => 'Last Name';

  @override
  String get dobScreenTitle => 'What\'s your date of birth?';

  @override
  String get dobMonthLabel => 'Month';

  @override
  String get dobDayLabel => 'Day';

  @override
  String get dobYearLabel => 'Year';

  @override
  String get welcomeTitle => 'Welcome to the world of J\'donuts';

  @override
  String get letsExploreButton => 'Let\'s explore';

  @override
  String get homeOfflineBanner =>
      'You\'re offline. Showing the last saved data.';

  @override
  String homeOfflineBannerUpdated(int minutes) {
    return 'You\'re offline. Updated $minutes min ago.';
  }

  @override
  String get nothingHereYet => 'Nothing here yet.';

  @override
  String get noNearbyShopsFound => 'No nearby shops found.';

  @override
  String get noBannersRightNow => 'No banners right now.';

  @override
  String get exploreNow => 'Explore now';

  @override
  String get orderOnline => 'Order Online';

  @override
  String nearbyShopsTitle(int count) {
    return 'There are $count J\'Donut shops';
  }

  @override
  String memberTierCaption(String tier) {
    return '$tier member';
  }

  @override
  String memberPointsLeft(int points, String tier) {
    return '$points points left to become $tier Member';
  }

  @override
  String get newBadge => 'New';

  @override
  String discountOff(int percent) {
    return '$percent% off';
  }

  @override
  String priceMmk(String price) {
    return '$price MMK';
  }

  @override
  String get addedToCartMessage => 'Added to cart';

  @override
  String get whatsThis => 'What\'s this?';

  @override
  String get addToCartLabel => 'Add to cart';

  @override
  String get earnTab => 'Earn';

  @override
  String get giftTab => 'Gift';

  @override
  String get rewardsTitle => 'J\' Donuts Rewards';

  @override
  String get rewardsBadgeLabel => 'Rewards';

  @override
  String get totalPointsLabel => 'Total points';

  @override
  String get tierHereNow => 'You\'re here now';

  @override
  String tierRemaining(int points, String tier) {
    return '$points pts Remaining to become $tier';
  }

  @override
  String get tierSoon => 'You\'ll be here soon';

  @override
  String get tierReached => 'Reached';

  @override
  String get earnMoreTab => 'Eat more earn more';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

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
