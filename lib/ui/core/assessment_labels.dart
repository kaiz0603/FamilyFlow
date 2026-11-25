import '../../domain/models/assessment.dart';
import '../../l10n/app_localizations.dart';

extension StyleText on ParentingStyle {
  String label(AppLocalizations l) => switch (this) {
    ParentingStyle.authoritative => l.styleAuthoritative,
    ParentingStyle.authoritarian => l.styleAuthoritarian,
    ParentingStyle.permissive => l.stylePermissive,
    ParentingStyle.neglectful => l.styleNeglectful,
  };

  String description(AppLocalizations l) => switch (this) {
    ParentingStyle.authoritative => l.styleDescAuthoritative,
    ParentingStyle.authoritarian => l.styleDescAuthoritarian,
    ParentingStyle.permissive => l.styleDescPermissive,
    ParentingStyle.neglectful => l.styleDescNeglectful,
  };
}

String tagLabel(AppLocalizations l, String tag) => switch (tag) {
  'bedtime' => l.tagBedtime,
  'screens' => l.tagScreens,
  'study' => l.tagStudy,
  'friends' => l.tagFriends,
  'chores' => l.tagChores,
  'emotions' => l.tagEmotions,
  'money' => l.tagMoney,
  'respect' => l.tagRespect,
  _ => tag,
};
