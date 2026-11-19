import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FamilyFlow'**
  String get appTitle;

  /// Bottom navigation tab: family activity and entry cards
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// Bottom navigation tab: parent vs child perception chart
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get tabCompare;

  /// Bottom navigation tab: advice library
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get tabAdvice;

  /// Bottom navigation tab: settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// Placeholder body for screens not built yet
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'See your family through each other\'s eyes.'**
  String get welcomeTagline;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a link to set a new password.'**
  String get resetPasswordBody;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a reset link is on its way.'**
  String get resetEmailSent;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'New to FamilyFlow? Create an account'**
  String get noAccountYet;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'This sets which questionnaire and advice you get. Your role and birth year can\'t be changed later.'**
  String get profileSetupIntro;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'I am a'**
  String get roleLabel;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @roleChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get roleChild;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Name shown to your family'**
  String get displayName;

  /// No description provided for @birthYear.
  ///
  /// In en, this message translates to:
  /// **'Birth year'**
  String get birthYear;

  /// No description provided for @childPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your parents will only see your overall scores, never your individual answers.'**
  String get childPrivacyNote;

  /// No description provided for @useAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get useAnotherAccount;

  /// No description provided for @underAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'FamilyFlow is for ages 13 and up'**
  String get underAgeTitle;

  /// No description provided for @underAgeBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your interest! FamilyFlow is not available for children under 13 yet. This account will be removed and no information is kept.'**
  String get underAgeBody;

  /// No description provided for @parentTooYoung.
  ///
  /// In en, this message translates to:
  /// **'Parents must be 18 or older. If you\'re under 18, choose Child.'**
  String get parentTooYoung;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @invalidEmailField.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmailField;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'{max} characters at most'**
  String nameTooLong(int max);

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageZh.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageZh;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your profile and sign-in. It cannot be undone. Enter your password to confirm.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountConfirm;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errNetwork;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get errInvalidCredentials;

  /// No description provided for @errEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in.'**
  String get errEmailInUse;

  /// No description provided for @errWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'That password is too weak. Use at least 8 characters.'**
  String get errWeakPassword;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address doesn\'t look right.'**
  String get errInvalidEmail;

  /// No description provided for @errTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get errTooManyRequests;

  /// No description provided for @errRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, sign in again and retry.'**
  String get errRequiresRecentLogin;

  /// No description provided for @errPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get errPermissionDenied;

  /// No description provided for @errUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errUnknown;

  /// No description provided for @familySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your family'**
  String get familySetupTitle;

  /// No description provided for @familySetupParentBody.
  ///
  /// In en, this message translates to:
  /// **'Create a family and invite your children, or join your partner\'s family with their invite code.'**
  String get familySetupParentBody;

  /// No description provided for @familySetupChildBody.
  ///
  /// In en, this message translates to:
  /// **'Ask a parent for your family\'s invite code, then send a request to join.'**
  String get familySetupChildBody;

  /// No description provided for @createFamily.
  ///
  /// In en, this message translates to:
  /// **'Create family'**
  String get createFamily;

  /// No description provided for @familyName.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyName;

  /// No description provided for @familyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The Lins'**
  String get familyNameHint;

  /// No description provided for @joinFamily.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get joinFamily;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @requestPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get requestPendingTitle;

  /// No description provided for @requestPendingBody.
  ///
  /// In en, this message translates to:
  /// **'A parent in the family needs to approve your request. You\'ll move in automatically.'**
  String get requestPendingBody;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @requestRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestRejectedTitle;

  /// No description provided for @requestRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'A parent declined your request. Check the code with them and try again.'**
  String get requestRejectedBody;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite family members'**
  String get inviteTitle;

  /// No description provided for @inviteBody.
  ///
  /// In en, this message translates to:
  /// **'Share this code. You\'ll approve each person before they join.'**
  String get inviteBody;

  /// No description provided for @inviteExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String inviteExpires(String date);

  /// No description provided for @generateCode.
  ///
  /// In en, this message translates to:
  /// **'Get an invite code'**
  String get generateCode;

  /// No description provided for @newCode.
  ///
  /// In en, this message translates to:
  /// **'New code'**
  String get newCode;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'Join our family on FamilyFlow with invite code {code}'**
  String inviteShareText(String code);

  /// No description provided for @pendingRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting to join'**
  String get pendingRequestsTitle;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get reject;

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersTitle;

  /// No description provided for @youSuffix.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get youSuffix;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMember;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeMemberTitle(String name);

  /// No description provided for @removeMemberBody.
  ///
  /// In en, this message translates to:
  /// **'They lose access to this family\'s results and challenges.'**
  String get removeMemberBody;

  /// No description provided for @leaveFamily.
  ///
  /// In en, this message translates to:
  /// **'Leave family'**
  String get leaveFamily;

  /// No description provided for @leaveFamilyBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll stop seeing this family\'s results and challenges. Your own results here are removed.'**
  String get leaveFamilyBody;

  /// No description provided for @leaveFamilyLastParentBody.
  ///
  /// In en, this message translates to:
  /// **'If you are the last parent, the family is removed for everyone.'**
  String get leaveFamilyLastParentBody;

  /// No description provided for @deleteAccountFamilyNote.
  ///
  /// In en, this message translates to:
  /// **'You will also leave your family. If you are its last parent, the family is removed for everyone.'**
  String get deleteAccountFamilyNote;

  /// No description provided for @errInvalidInviteCode.
  ///
  /// In en, this message translates to:
  /// **'That code doesn\'t work. It may have expired — ask for a new one.'**
  String get errInvalidInviteCode;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
