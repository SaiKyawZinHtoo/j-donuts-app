// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'ဂျေ ဒိုနပ်';

  @override
  String get onboardingTitle => 'မည်သည့်စိတ်ခံစားချက်အတွက်မဆို ဝိုင်းပုံစားစရာ';

  @override
  String get getStartedButton => 'စတင်မည်';

  @override
  String get alreadyHaveAccount => 'အကောင့်ရှိပြီးသားလား? ';

  @override
  String get loginLink => 'လော့ဂ်အင်';

  @override
  String get termsPrivacyNotice =>
      'ဆက်လက်လုပ်ဆောင်ခြင်းဖြင့် သင်သည် ကျွန်ုပ်တို့၏ Terms of Use နှင့် Privacy Policy တို့ကို ဖတ်ရှုပြီး သဘောတူကြောင်း အသိအမှတ်ပြုရာရောက်ပါသည်။';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String socialSignInUnavailableMessage(String provider) {
    return '$provider ဖြင့် လော့ဂ်အင်ဝင်ခြင်းကို မထည့်သွင်းရသေးပါ။';
  }

  @override
  String legalPlaceholderSuffix(String doc) {
    return '$doc နမူနာ';
  }

  @override
  String get phoneScreenTitle => 'သင့်ဖုန်းနံပါတ်ကို ရိုက်ထည့်ပါ';

  @override
  String get phoneCountryCode => '+95';

  @override
  String get phoneHint => '9xxxxxxxx';

  @override
  String get phoneNotFoundRegister =>
      'ဤနံပါတ်ကို ရှာမတွေ့ပါ။ အကောင့်သစ်ဖွင့်မလား?';

  @override
  String get continueButton => 'ရှေ့ဆက်မည်';

  @override
  String get otpScreenTitle => 'သင့်နံပါတ်ကို အတည်ပြုပါ';

  @override
  String otpSubtitle(String phone) {
    return 'ဂဏန်း ၆ လုံးပါ OTP ကို $phone သို့ ပို့ထားပါသည်';
  }

  @override
  String otpIncorrectCode(int attemptsLeft) {
    return 'ကုဒ်မှားနေပါသည်၊ ကြိုးစားခွင့် $attemptsLeft ကြိမ် ကျန်ပါသည်။';
  }

  @override
  String get otpLocked =>
      'ကြိုးစားမှု အကြိမ်များလွန်းပါပြီ။ ကုဒ်ကို ထပ်မံပေးပို့ပါ။';

  @override
  String get didntReceiveCode => 'ကုဒ်မရရှိသေးဘူးလား?';

  @override
  String get resendCode => 'ကုဒ်ပြန်ပို့မည်';

  @override
  String resendIn(String time) {
    return '$time အတွင်း ပြန်ပို့ပါမည်';
  }

  @override
  String get nameScreenTitle => 'သင့်နာမည်ကဘာလဲ?';

  @override
  String get firstNameLabel => 'နာမည်';

  @override
  String get lastNameLabel => 'မျိုးနွယ်အမည်';

  @override
  String get dobScreenTitle => 'သင့်မွေးနေ့ ဘယ်တုန်းကလဲ?';

  @override
  String get dobMonthLabel => 'လ';

  @override
  String get dobDayLabel => 'ရက်';

  @override
  String get dobYearLabel => 'နှစ်';

  @override
  String get welcomeTitle => 'ကြိုဆိုပါတယ်!';

  @override
  String get letsExploreButton => 'လေ့လာကြည့်ရှုမည်';

  @override
  String get homeOfflineBanner =>
      'သင်သည် အော့ဖ်လိုင်းဖြစ်နေသည်။ နောက်ဆုံးသိမ်းဆည်းထားသော အချက်အလက်များကို ပြသထားသည်။';

  @override
  String get nothingHereYet => 'ဒီနေရာတွင် မရှိသေးပါ။';

  @override
  String get noNearbyShopsFound => 'အနီးအနားဆိုင်များ မတွေ့ပါ။';

  @override
  String get noBannersRightNow => 'ယခု ကြော်ငြာများ မရှိပါ။';

  @override
  String nearbyShopsTitle(int count) {
    return 'ဂျေဒိုနပ် ဆိုင် $count ခု ရှိပါသည်';
  }

  @override
  String memberTierStatus(String tier, int points) {
    return '$tier အဆင့် · နောက်အဆင့်အတွက် $points အမှတ်လိုသည်';
  }

  @override
  String get newBadge => 'အသစ်';

  @override
  String discountBadge(int percent) {
    return '-$percent%';
  }

  @override
  String priceMmk(String price) {
    return '$price ကျပ်';
  }

  @override
  String get productAppBarTitle => 'ကုန်ပစ္စည်း';

  @override
  String get addedToCartMessage => 'စျေးခြင်းထဲထည့်ပြီးပါပြီ';

  @override
  String get whatsThis => 'ဒါကဘာလဲ?';

  @override
  String addToCartButton(String total) {
    return 'စျေးခြင်းထဲထည့်မည် · $total ကျပ်';
  }

  @override
  String get earnTab => 'ရယူရန်';

  @override
  String get giftTab => 'လက်ဆောင်';

  @override
  String get homeTabLabel => 'ပင်မစာမျက်နှာ';

  @override
  String get exploreTabLabel => 'လေ့လာမည်';

  @override
  String get rewardsTabLabel => 'ဆုလာဘ်များ';

  @override
  String get walletTabLabel => 'ပိုက်ဆံအိတ်';

  @override
  String get settingsTabLabel => 'ဆက်တင်များ';

  @override
  String comingSoon(String label) {
    return '$label မကြာမီလာမည်';
  }

  @override
  String get logOut => 'ထွက်ရန်';
}
