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

  @override
  String get familySetupTitle => '建立你的家庭';

  @override
  String get familySetupParentBody => '创建一个家庭并邀请孩子加入，或者用伴侣给你的邀请码加入他们的家庭。';

  @override
  String get familySetupChildBody => '向家长要家庭的邀请码，然后发送加入申请。';

  @override
  String get createFamily => '创建家庭';

  @override
  String get familyName => '家庭名称';

  @override
  String get familyNameHint => '例如：林家';

  @override
  String get joinFamily => '用邀请码加入';

  @override
  String get inviteCode => '邀请码';

  @override
  String get sendRequest => '发送申请';

  @override
  String get requestPendingTitle => '等待批准';

  @override
  String get requestPendingBody => '需要家里的一位家长批准你的申请，批准后会自动进入家庭。';

  @override
  String get cancelRequest => '取消申请';

  @override
  String get requestRejectedTitle => '申请未通过';

  @override
  String get requestRejectedBody => '家长没有通过你的申请。请和他们确认邀请码后再试。';

  @override
  String get inviteTitle => '邀请家人';

  @override
  String get inviteBody => '把这个邀请码发给家人。每个人加入前都需要你批准。';

  @override
  String inviteExpires(String date) {
    return '$date 到期';
  }

  @override
  String get generateCode => '获取邀请码';

  @override
  String get newCode => '换一个';

  @override
  String get share => '分享';

  @override
  String inviteShareText(String code) {
    return '用邀请码 $code 加入我们在 FamilyFlow 上的家庭';
  }

  @override
  String get pendingRequestsTitle => '等待加入';

  @override
  String get approve => '批准';

  @override
  String get reject => '拒绝';

  @override
  String get membersTitle => '成员';

  @override
  String get youSuffix => '（你）';

  @override
  String get removeMember => '移除';

  @override
  String removeMemberTitle(String name) {
    return '移除 $name？';
  }

  @override
  String get removeMemberBody => '对方将无法再查看这个家庭的结果和挑战。';

  @override
  String get leaveFamily => '退出家庭';

  @override
  String get leaveFamilyBody => '你将不再看到这个家庭的结果和挑战，你在这里的结果也会被删除。';

  @override
  String get leaveFamilyLastParentBody => '如果你是最后一位家长，这个家庭会对所有人删除。';

  @override
  String get deleteAccountFamilyNote => '你也会退出家庭。如果你是最后一位家长，这个家庭会对所有人删除。';

  @override
  String get errInvalidInviteCode => '这个邀请码无效，可能已经过期，请向家长要一个新的。';

  @override
  String get assessmentTitleSelf => '家长自评';

  @override
  String assessmentTitleChild(String name) {
    return '你眼中的$name';
  }

  @override
  String get assessmentIntro => '共 24 题，约 5 分钟。按平时的真实情况作答，没有对错之分。';

  @override
  String get assessmentDisclaimer =>
      '本测评是帮助家庭成员自我反思的工具，不是心理诊断。如果你或家人感到持续的痛苦或不安全，请联系学校辅导老师或专业人士。';

  @override
  String assessmentChildPrivacy(String name) {
    return '$name会看到你的总体得分和类型，看不到你每道题的答案。';
  }

  @override
  String get startAssessment => '开始';

  @override
  String get resumeAssessment => '继续上次的进度';

  @override
  String questionProgress(int current, int total) {
    return '第 $current / $total 题';
  }

  @override
  String get previousQuestion => '上一题';

  @override
  String get seeResult => '查看结果';

  @override
  String get resultTitle => '结果';

  @override
  String get resultLeadSelf => '你的方式更接近';

  @override
  String resultLeadChild(String name) {
    return '在你眼中，$name的方式更接近';
  }

  @override
  String get dimWarmth => '温暖回应';

  @override
  String get dimDemandingness => '规则要求';

  @override
  String get styleAuthoritative => '民主权威型';

  @override
  String get styleAuthoritarian => '独断专权型';

  @override
  String get stylePermissive => '宽松溺爱型';

  @override
  String get styleNeglectful => '忽视冷漠型';

  @override
  String get styleDescAuthoritative => '温暖回应和规则要求都比较高：既关心孩子的感受，也有清楚、讲道理的规则。';

  @override
  String get styleDescAuthoritarian => '规则要求高，温暖回应较低：重视纪律和服从，较少解释和倾听。';

  @override
  String get styleDescPermissive => '温暖回应高，规则要求较低：关系亲近，但规则和跟进较少。';

  @override
  String get styleDescNeglectful => '温暖回应和规则要求都较低：日常的关心和规则都比较少，常见于忙碌或压力大的家庭。';

  @override
  String get tryThis => '可以试试';

  @override
  String get seeAllAdvice => '查看全部建议';

  @override
  String get done => '完成';

  @override
  String get selfCheckTitle => '家长自评';

  @override
  String get notDoneYet => '还没有做';

  @override
  String lastResult(String style, String date) {
    return '上次：$style · $date';
  }

  @override
  String get takeIt => '开始';

  @override
  String get retake => '重新测评';

  @override
  String get rateParentsTitle => '评一评家长';

  @override
  String get notRatedYet => '还没有评';

  @override
  String get rateAction => '去评';

  @override
  String get allStyles => '全部类型';

  @override
  String get allTopics => '全部话题';

  @override
  String get tagBedtime => '作息';

  @override
  String get tagScreens => '屏幕时间';

  @override
  String get tagStudy => '学习';

  @override
  String get tagFriends => '朋友';

  @override
  String get tagChores => '家务';

  @override
  String get tagEmotions => '情绪';

  @override
  String get tagMoney => '零用钱';

  @override
  String get tagRespect => '沟通与尊重';

  @override
  String get weeklyChallenge => '本周挑战';

  @override
  String get adviceEmpty => '没有符合条件的建议。';
}
