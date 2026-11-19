// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FamilyFlow';

  @override
  String get tabHome => '首页';

  @override
  String get tabCompare => '对比';

  @override
  String get tabAdvice => '建议';

  @override
  String get tabSettings => '设置';

  @override
  String get comingSoon => '即将推出';

  @override
  String get welcomeTagline => '换个视角，看见彼此眼中的家。';

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册账号';

  @override
  String get signOut => '退出登录';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get passwordHint => '至少 8 个字符';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get resetPasswordTitle => '重设密码';

  @override
  String get resetPasswordBody => '我们会发一封邮件，帮你设置新密码。';

  @override
  String get sendLink => '发送链接';

  @override
  String get resetEmailSent => '如果该邮箱已注册，重设链接已经发出。';

  @override
  String get noAccountYet => '第一次使用？注册账号';

  @override
  String get haveAccount => '已有账号？去登录';

  @override
  String get cancel => '取消';

  @override
  String get ok => '好';

  @override
  String get continueAction => '继续';

  @override
  String get profileSetupTitle => '关于你';

  @override
  String get profileSetupIntro => '这会决定你看到的问卷和建议。身份和出生年份之后不能修改。';

  @override
  String get roleLabel => '我是';

  @override
  String get roleParent => '家长';

  @override
  String get roleChild => '孩子';

  @override
  String get displayName => '家人看到的名字';

  @override
  String get birthYear => '出生年份';

  @override
  String get childPrivacyNote => '家长只能看到你的总体得分，看不到你每道题的答案。';

  @override
  String get useAnotherAccount => '换一个账号';

  @override
  String get underAgeTitle => 'FamilyFlow 适合 13 岁及以上';

  @override
  String get underAgeBody =>
      '谢谢你的关注！FamilyFlow 暂时不开放给 13 岁以下的孩子使用。这个账号会被删除，不会保留任何信息。';

  @override
  String get parentTooYoung => '家长需年满 18 岁。如果你未满 18 岁，请选择“孩子”。';

  @override
  String get fieldRequired => '必填';

  @override
  String get invalidEmailField => '请输入有效的邮箱';

  @override
  String get passwordTooShort => '至少 8 个字符';

  @override
  String nameTooLong(int max) {
    return '最多 $max 个字符';
  }

  @override
  String get settingsProfile => '个人资料';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageZh => '中文';

  @override
  String get languageEn => 'English';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get deleteAccountBody => '这会永久删除你的资料和登录方式，无法恢复。请输入密码确认。';

  @override
  String get deleteAccountConfirm => '永久删除';

  @override
  String get errNetwork => '没有网络连接，请检查网络后重试。';

  @override
  String get errInvalidCredentials => '邮箱或密码不正确。';

  @override
  String get errEmailInUse => '这个邮箱已经注册过了，试试直接登录。';

  @override
  String get errWeakPassword => '密码太简单了，请至少使用 8 个字符。';

  @override
  String get errInvalidEmail => '邮箱地址格式不对。';

  @override
  String get errTooManyRequests => '尝试次数太多，请稍后再试。';

  @override
  String get errRequiresRecentLogin => '为了安全，请重新登录后再试。';

  @override
  String get errPermissionDenied => '你没有权限进行这个操作。';

  @override
  String get errUnknown => '出了点问题，请重试。';
}
