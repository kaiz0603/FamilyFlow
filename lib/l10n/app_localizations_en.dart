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
  String get comingSoon => 'Coming soon';

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
}
