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

  /// No description provided for @assessmentTitleSelf.
  ///
  /// In en, this message translates to:
  /// **'Parenting self-check'**
  String get assessmentTitleSelf;

  /// No description provided for @assessmentTitleChild.
  ///
  /// In en, this message translates to:
  /// **'How you see {name}'**
  String assessmentTitleChild(String name);

  /// No description provided for @assessmentIntro.
  ///
  /// In en, this message translates to:
  /// **'24 statements, about 5 minutes. Answer how things usually are. There are no right or wrong answers.'**
  String get assessmentIntro;

  /// No description provided for @assessmentDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is a self-reflection tool for families, not a psychological assessment. If you or someone in your family feels persistently distressed or unsafe, please reach out to a school counsellor or a professional.'**
  String get assessmentDisclaimer;

  /// No description provided for @assessmentChildPrivacy.
  ///
  /// In en, this message translates to:
  /// **'{name} will see your overall scores and style, never your individual answers.'**
  String assessmentChildPrivacy(String name);

  /// No description provided for @startAssessment.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startAssessment;

  /// No description provided for @resumeAssessment.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get resumeAssessment;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @previousQuestion.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get previousQuestion;

  /// No description provided for @seeResult.
  ///
  /// In en, this message translates to:
  /// **'See my result'**
  String get seeResult;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get resultTitle;

  /// No description provided for @resultLeadSelf.
  ///
  /// In en, this message translates to:
  /// **'Your style is closest to'**
  String get resultLeadSelf;

  /// No description provided for @resultLeadChild.
  ///
  /// In en, this message translates to:
  /// **'In your eyes, {name}\'s style is closest to'**
  String resultLeadChild(String name);

  /// No description provided for @dimWarmth.
  ///
  /// In en, this message translates to:
  /// **'Warmth'**
  String get dimWarmth;

  /// No description provided for @dimDemandingness.
  ///
  /// In en, this message translates to:
  /// **'Demandingness'**
  String get dimDemandingness;

  /// No description provided for @styleAuthoritative.
  ///
  /// In en, this message translates to:
  /// **'Authoritative'**
  String get styleAuthoritative;

  /// No description provided for @styleAuthoritarian.
  ///
  /// In en, this message translates to:
  /// **'Authoritarian'**
  String get styleAuthoritarian;

  /// No description provided for @stylePermissive.
  ///
  /// In en, this message translates to:
  /// **'Permissive'**
  String get stylePermissive;

  /// No description provided for @styleNeglectful.
  ///
  /// In en, this message translates to:
  /// **'Neglectful'**
  String get styleNeglectful;

  /// No description provided for @styleDescAuthoritative.
  ///
  /// In en, this message translates to:
  /// **'High warmth and high demandingness: caring about feelings while keeping clear rules that are explained.'**
  String get styleDescAuthoritative;

  /// No description provided for @styleDescAuthoritarian.
  ///
  /// In en, this message translates to:
  /// **'High demandingness, lower warmth: discipline and obedience come first, with less explaining and listening.'**
  String get styleDescAuthoritarian;

  /// No description provided for @styleDescPermissive.
  ///
  /// In en, this message translates to:
  /// **'High warmth, lower demandingness: a close relationship, with few rules or little follow-through.'**
  String get styleDescPermissive;

  /// No description provided for @styleDescNeglectful.
  ///
  /// In en, this message translates to:
  /// **'Lower warmth and lower demandingness: little day-to-day attention or structure, which is common when a family is busy or under stress.'**
  String get styleDescNeglectful;

  /// No description provided for @tryThis.
  ///
  /// In en, this message translates to:
  /// **'Try this'**
  String get tryThis;

  /// No description provided for @seeAllAdvice.
  ///
  /// In en, this message translates to:
  /// **'See all advice'**
  String get seeAllAdvice;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selfCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Your self-check'**
  String get selfCheckTitle;

  /// No description provided for @notDoneYet.
  ///
  /// In en, this message translates to:
  /// **'Not done yet'**
  String get notDoneYet;

  /// No description provided for @lastResult.
  ///
  /// In en, this message translates to:
  /// **'Last: {style} · {date}'**
  String lastResult(String style, String date);

  /// No description provided for @takeIt.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get takeIt;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @rateParentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your parents'**
  String get rateParentsTitle;

  /// No description provided for @notRatedYet.
  ///
  /// In en, this message translates to:
  /// **'Not rated yet'**
  String get notRatedYet;

  /// No description provided for @rateAction.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateAction;

  /// No description provided for @allStyles.
  ///
  /// In en, this message translates to:
  /// **'All styles'**
  String get allStyles;

  /// No description provided for @allTopics.
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get allTopics;

  /// No description provided for @tagBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get tagBedtime;

  /// No description provided for @tagScreens.
  ///
  /// In en, this message translates to:
  /// **'Screens'**
  String get tagScreens;

  /// No description provided for @tagStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get tagStudy;

  /// No description provided for @tagFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get tagFriends;

  /// No description provided for @tagChores.
  ///
  /// In en, this message translates to:
  /// **'Chores'**
  String get tagChores;

  /// No description provided for @tagEmotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get tagEmotions;

  /// No description provided for @tagMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get tagMoney;

  /// No description provided for @tagRespect.
  ///
  /// In en, this message translates to:
  /// **'Respect'**
  String get tagRespect;

  /// No description provided for @weeklyChallenge.
  ///
  /// In en, this message translates to:
  /// **'This week\'s challenge'**
  String get weeklyChallenge;

  /// No description provided for @adviceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No advice matches these filters.'**
  String get adviceEmpty;

  /// No description provided for @compareNoFamily.
  ///
  /// In en, this message translates to:
  /// **'Create or join a Family on Home to compare views.'**
  String get compareNoFamily;

  /// No description provided for @compareSelfName.
  ///
  /// In en, this message translates to:
  /// **'{name} (self)'**
  String compareSelfName(String name);

  /// No description provided for @compareInviteSelf.
  ///
  /// In en, this message translates to:
  /// **'Take your self-check to put your own view on the chart.'**
  String get compareInviteSelf;

  /// No description provided for @compareInviteChildren.
  ///
  /// In en, this message translates to:
  /// **'Ask your Children to rate you. Their views show up here.'**
  String get compareInviteChildren;

  /// No description provided for @compareNoChildren.
  ///
  /// In en, this message translates to:
  /// **'No Children in the Family yet. Invite one from Home.'**
  String get compareNoChildren;

  /// No description provided for @compareParentNoSelf.
  ///
  /// In en, this message translates to:
  /// **'{parent} has not done a self-check yet. Ask them to take it.'**
  String compareParentNoSelf(String parent);

  /// No description provided for @compareChildNone.
  ///
  /// In en, this message translates to:
  /// **'Rate a Parent to see how your views compare.'**
  String get compareChildNone;

  /// No description provided for @compareRateParent.
  ///
  /// In en, this message translates to:
  /// **'Rate {parent}'**
  String compareRateParent(String parent);

  /// No description provided for @gapSame.
  ///
  /// In en, this message translates to:
  /// **'{child} and {parent} see {dimension, select, warmth{warmth} other{demandingness}} about the same way.'**
  String gapSame(String child, String parent, String dimension);

  /// No description provided for @gapDiff.
  ///
  /// In en, this message translates to:
  /// **'{child} experiences {size, select, large{much} other{a bit}} {direction, select, more{more} other{less}} {dimension, select, warmth{warmth} other{demandingness}} than {parent} sees in their self-check.'**
  String gapDiff(
    String child,
    String parent,
    String dimension,
    String size,
    String direction,
  );

  /// No description provided for @chartQuadrantLabel.
  ///
  /// In en, this message translates to:
  /// **'Quadrant chart. Warmth runs across, demandingness up, the midpoint is 50.'**
  String get chartQuadrantLabel;

  /// No description provided for @chartPoint.
  ///
  /// In en, this message translates to:
  /// **'{name}: warmth {warmth}, demandingness {demandingness}, {style}.'**
  String chartPoint(String name, int warmth, int demandingness, String style);

  /// No description provided for @chartEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results yet.'**
  String get chartEmpty;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySummary.
  ///
  /// In en, this message translates to:
  /// **'{dimension} over time. {series}'**
  String historySummary(String dimension, String series);

  /// No description provided for @historyNotComparable.
  ///
  /// In en, this message translates to:
  /// **'A dashed line marks a new question version. Scores on either side of it are not directly comparable.'**
  String get historyNotComparable;

  /// No description provided for @historyVersion.
  ///
  /// In en, this message translates to:
  /// **'v{major}'**
  String historyVersion(String major);

  /// No description provided for @startChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start as a Family Challenge'**
  String get startChallenge;

  /// No description provided for @newChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'New Challenge'**
  String get newChallengeTitle;

  /// No description provided for @challengeWeekInfo.
  ///
  /// In en, this message translates to:
  /// **'7 days from today. Each Participant checks in once a day.'**
  String get challengeWeekInfo;

  /// No description provided for @challengeParticipants.
  ///
  /// In en, this message translates to:
  /// **'Who takes part?'**
  String get challengeParticipants;

  /// No description provided for @challengeNeedParticipant.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one person.'**
  String get challengeNeedParticipant;

  /// No description provided for @startAction.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startAction;

  /// No description provided for @errChallengeActive.
  ///
  /// In en, this message translates to:
  /// **'Your family already has a Challenge this week. Finish that one first.'**
  String get errChallengeActive;

  /// No description provided for @challengeTitle.
  ///
  /// In en, this message translates to:
  /// **'This week\'s Challenge'**
  String get challengeTitle;

  /// No description provided for @challengeDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of 7'**
  String challengeDay(int day);

  /// No description provided for @checkInToday.
  ///
  /// In en, this message translates to:
  /// **'Check in today'**
  String get checkInToday;

  /// No description provided for @checkedInToday.
  ///
  /// In en, this message translates to:
  /// **'You checked in today.'**
  String get checkedInToday;

  /// No description provided for @challengeNone.
  ///
  /// In en, this message translates to:
  /// **'No Challenge yet. Pick one from an Advice card.'**
  String get challengeNone;

  /// No description provided for @browseAdvice.
  ///
  /// In en, this message translates to:
  /// **'Browse Advice'**
  String get browseAdvice;

  /// No description provided for @challengeFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Week finished'**
  String get challengeFinishedTitle;

  /// No description provided for @challengeRowSummary.
  ///
  /// In en, this message translates to:
  /// **'{name}: {count} of 7 days'**
  String challengeRowSummary(String name, int count);

  /// No description provided for @startNextChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start the next one'**
  String get startNextChallenge;

  /// No description provided for @formerMember.
  ///
  /// In en, this message translates to:
  /// **'Former member'**
  String get formerMember;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get activityTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet.'**
  String get activityEmpty;

  /// No description provided for @activityMemberJoined.
  ///
  /// In en, this message translates to:
  /// **'{name} joined the family'**
  String activityMemberJoined(String name);

  /// No description provided for @activityMemberLeft.
  ///
  /// In en, this message translates to:
  /// **'{name} left the family'**
  String activityMemberLeft(String name);

  /// No description provided for @activityAssessmentDone.
  ///
  /// In en, this message translates to:
  /// **'{name} finished an Assessment'**
  String activityAssessmentDone(String name);

  /// No description provided for @activityChallengeStarted.
  ///
  /// In en, this message translates to:
  /// **'{name} started a Challenge'**
  String activityChallengeStarted(String name);

  /// No description provided for @activityChallengeFinished.
  ///
  /// In en, this message translates to:
  /// **'A Challenge week finished'**
  String get activityChallengeFinished;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// No description provided for @remindersWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly check-in'**
  String get remindersWeekly;

  /// No description provided for @remindersWeeklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Once a week: how is the family doing?'**
  String get remindersWeeklySubtitle;

  /// No description provided for @remindersDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge check-in'**
  String get remindersDaily;

  /// No description provided for @remindersDailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every day of a Challenge you take part in, until you check in.'**
  String get remindersDailySubtitle;

  /// No description provided for @remindersDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get remindersDay;

  /// No description provided for @remindersTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get remindersTime;

  /// No description provided for @remindersPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for this app. Allow them in the system settings to get Reminders.'**
  String get remindersPermissionDenied;

  /// No description provided for @reminderWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'Take a minute to check in with your family.'**
  String get reminderWeeklyBody;

  /// No description provided for @reminderDailyBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget today\'s Challenge check-in.'**
  String get reminderDailyBody;
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
