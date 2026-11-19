// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FamilyFlow';

  @override
  String get tabHome => 'Home';

  @override
  String get tabCompare => 'Compare';

  @override
  String get tabAdvice => 'Advice';

  @override
  String get tabSettings => 'Settings';

  @override
  String get welcomeTagline => 'See your family through each other\'s eyes.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordBody =>
      'We\'ll email you a link to set a new password.';

  @override
  String get sendLink => 'Send link';

  @override
  String get resetEmailSent =>
      'If an account exists for that email, a reset link is on its way.';

  @override
  String get noAccountYet => 'New to FamilyFlow? Create an account';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get continueAction => 'Continue';

  @override
  String get profileSetupTitle => 'About you';

  @override
  String get profileSetupIntro =>
      'This sets which questionnaire and advice you get. Your role and birth year can\'t be changed later.';

  @override
  String get roleLabel => 'I am a';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleChild => 'Child';

  @override
  String get displayName => 'Name shown to your family';

  @override
  String get birthYear => 'Birth year';

  @override
  String get childPrivacyNote =>
      'Your parents will only see your overall scores, never your individual answers.';

  @override
  String get useAnotherAccount => 'Use a different account';

  @override
  String get underAgeTitle => 'FamilyFlow is for ages 13 and up';

  @override
  String get underAgeBody =>
      'Thanks for your interest! FamilyFlow is not available for children under 13 yet. This account will be removed and no information is kept.';

  @override
  String get parentTooYoung =>
      'Parents must be 18 or older. If you\'re under 18, choose Child.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get invalidEmailField => 'Enter a valid email';

  @override
  String get passwordTooShort => 'Use at least 8 characters';

  @override
  String nameTooLong(int max) {
    return '$max characters at most';
  }

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageZh => '中文';

  @override
  String get languageEn => 'English';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your profile and sign-in. It cannot be undone. Enter your password to confirm.';

  @override
  String get deleteAccountConfirm => 'Delete permanently';

  @override
  String get errNetwork => 'No connection. Check your internet and try again.';

  @override
  String get errInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get errEmailInUse =>
      'An account with this email already exists. Try signing in.';

  @override
  String get errWeakPassword =>
      'That password is too weak. Use at least 8 characters.';

  @override
  String get errInvalidEmail => 'That email address doesn\'t look right.';

  @override
  String get errTooManyRequests =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get errRequiresRecentLogin =>
      'For your security, sign in again and retry.';

  @override
  String get errPermissionDenied => 'You don\'t have permission to do that.';

  @override
  String get errUnknown => 'Something went wrong. Please try again.';

  @override
  String get familySetupTitle => 'Set up your family';

  @override
  String get familySetupParentBody =>
      'Create a family and invite your children, or join your partner\'s family with their invite code.';

  @override
  String get familySetupChildBody =>
      'Ask a parent for your family\'s invite code, then send a request to join.';

  @override
  String get createFamily => 'Create family';

  @override
  String get familyName => 'Family name';

  @override
  String get familyNameHint => 'e.g. The Lins';

  @override
  String get joinFamily => 'Join with a code';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get sendRequest => 'Send request';

  @override
  String get requestPendingTitle => 'Waiting for approval';

  @override
  String get requestPendingBody =>
      'A parent in the family needs to approve your request. You\'ll move in automatically.';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get requestRejectedTitle => 'Request declined';

  @override
  String get requestRejectedBody =>
      'A parent declined your request. Check the code with them and try again.';

  @override
  String get inviteTitle => 'Invite family members';

  @override
  String get inviteBody =>
      'Share this code. You\'ll approve each person before they join.';

  @override
  String inviteExpires(String date) {
    return 'Expires $date';
  }

  @override
  String get generateCode => 'Get an invite code';

  @override
  String get newCode => 'New code';

  @override
  String get share => 'Share';

  @override
  String inviteShareText(String code) {
    return 'Join our family on FamilyFlow with invite code $code';
  }

  @override
  String get pendingRequestsTitle => 'Waiting to join';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Decline';

  @override
  String get membersTitle => 'Members';

  @override
  String get youSuffix => '(you)';

  @override
  String get removeMember => 'Remove';

  @override
  String removeMemberTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeMemberBody =>
      'They lose access to this family\'s results and challenges.';

  @override
  String get leaveFamily => 'Leave family';

  @override
  String get leaveFamilyBody =>
      'You\'ll stop seeing this family\'s results and challenges. Your own results here are removed.';

  @override
  String get leaveFamilyLastParentBody =>
      'If you are the last parent, the family is removed for everyone.';

  @override
  String get deleteAccountFamilyNote =>
      'You will also leave your family. If you are its last parent, the family is removed for everyone.';

  @override
  String get errInvalidInviteCode =>
      'That code doesn\'t work. It may have expired — ask for a new one.';

  @override
  String get assessmentTitleSelf => 'Parenting self-check';

  @override
  String assessmentTitleChild(String name) {
    return 'How you see $name';
  }

  @override
  String get assessmentIntro =>
      '24 statements, about 5 minutes. Answer how things usually are. There are no right or wrong answers.';

  @override
  String get assessmentDisclaimer =>
      'This is a self-reflection tool for families, not a psychological assessment. If you or someone in your family feels persistently distressed or unsafe, please reach out to a school counsellor or a professional.';

  @override
  String assessmentChildPrivacy(String name) {
    return '$name will see your overall scores and style, never your individual answers.';
  }

  @override
  String get startAssessment => 'Start';

  @override
  String get resumeAssessment => 'Continue where you left off';

  @override
  String questionProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get previousQuestion => 'Back';

  @override
  String get seeResult => 'See my result';

  @override
  String get resultTitle => 'Your result';

  @override
  String get resultLeadSelf => 'Your style is closest to';

  @override
  String resultLeadChild(String name) {
    return 'In your eyes, $name\'s style is closest to';
  }

  @override
  String get dimWarmth => 'Warmth';

  @override
  String get dimDemandingness => 'Demandingness';

  @override
  String get styleAuthoritative => 'Authoritative';

  @override
  String get styleAuthoritarian => 'Authoritarian';

  @override
  String get stylePermissive => 'Permissive';

  @override
  String get styleNeglectful => 'Neglectful';

  @override
  String get styleDescAuthoritative =>
      'High warmth and high demandingness: caring about feelings while keeping clear rules that are explained.';

  @override
  String get styleDescAuthoritarian =>
      'High demandingness, lower warmth: discipline and obedience come first, with less explaining and listening.';

  @override
  String get styleDescPermissive =>
      'High warmth, lower demandingness: a close relationship, with few rules or little follow-through.';

  @override
  String get styleDescNeglectful =>
      'Lower warmth and lower demandingness: little day-to-day attention or structure, which is common when a family is busy or under stress.';

  @override
  String get tryThis => 'Try this';

  @override
  String get seeAllAdvice => 'See all advice';

  @override
  String get done => 'Done';

  @override
  String get selfCheckTitle => 'Your self-check';

  @override
  String get notDoneYet => 'Not done yet';

  @override
  String lastResult(String style, String date) {
    return 'Last: $style · $date';
  }

  @override
  String get takeIt => 'Start';

  @override
  String get retake => 'Retake';

  @override
  String get rateParentsTitle => 'Rate your parents';

  @override
  String get notRatedYet => 'Not rated yet';

  @override
  String get rateAction => 'Rate';

  @override
  String get allStyles => 'All styles';

  @override
  String get allTopics => 'All topics';

  @override
  String get tagBedtime => 'Bedtime';

  @override
  String get tagScreens => 'Screens';

  @override
  String get tagStudy => 'Study';

  @override
  String get tagFriends => 'Friends';

  @override
  String get tagChores => 'Chores';

  @override
  String get tagEmotions => 'Emotions';

  @override
  String get tagMoney => 'Money';

  @override
  String get tagRespect => 'Respect';

  @override
  String get weeklyChallenge => 'This week\'s challenge';

  @override
  String get adviceEmpty => 'No advice matches these filters.';

  @override
  String get compareNoFamily =>
      'Create or join a Family on Home to compare views.';

  @override
  String compareSelfName(String name) {
    return '$name (self)';
  }

  @override
  String get compareInviteSelf =>
      'Take your self-check to put your own view on the chart.';

  @override
  String get compareInviteChildren =>
      'Ask your Children to rate you. Their views show up here.';

  @override
  String get compareNoChildren =>
      'No Children in the Family yet. Invite one from Home.';

  @override
  String compareParentNoSelf(String parent) {
    return '$parent has not done a self-check yet. Ask them to take it.';
  }

  @override
  String get compareChildNone => 'Rate a Parent to see how your views compare.';

  @override
  String compareRateParent(String parent) {
    return 'Rate $parent';
  }

  @override
  String gapSame(String child, String parent, String dimension) {
    String _temp0 = intl.Intl.selectLogic(dimension, {
      'warmth': 'warmth',
      'other': 'demandingness',
    });
    return '$child and $parent see $_temp0 about the same way.';
  }

  @override
  String gapDiff(
    String child,
    String parent,
    String dimension,
    String size,
    String direction,
  ) {
    String _temp0 = intl.Intl.selectLogic(size, {
      'large': 'much',
      'other': 'a bit',
    });
    String _temp1 = intl.Intl.selectLogic(direction, {
      'more': 'more',
      'other': 'less',
    });
    String _temp2 = intl.Intl.selectLogic(dimension, {
      'warmth': 'warmth',
      'other': 'demandingness',
    });
    return '$child experiences $_temp0 $_temp1 $_temp2 than $parent sees in their self-check.';
  }

  @override
  String get chartQuadrantLabel =>
      'Quadrant chart. Warmth runs across, demandingness up, the midpoint is 50.';

  @override
  String chartPoint(String name, int warmth, int demandingness, String style) {
    return '$name: warmth $warmth, demandingness $demandingness, $style.';
  }

  @override
  String get chartEmpty => 'No results yet.';

  @override
  String get historyTitle => 'History';

  @override
  String historySummary(String dimension, String series) {
    return '$dimension over time. $series';
  }

  @override
  String get historyNotComparable =>
      'A dashed line marks a new question version. Scores on either side of it are not directly comparable.';

  @override
  String historyVersion(String major) {
    return 'v$major';
  }
}
