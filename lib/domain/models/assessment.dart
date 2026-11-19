import 'user_profile.dart';

/// Pure-Dart content and assessment models (docs/ASSESSMENT.md).

enum Dimension { warmth, demandingness }

enum Perspective {
  self('self', 'parent_self'),
  childView('child_view', 'child_view');

  const Perspective(this.stored, this.formKey);

  /// Value in Firestore `assessments.perspective`.
  final String stored;

  /// Key in `assessment.<lang>.json` `forms`.
  final String formKey;

  static Perspective fromStored(String s) =>
      values.firstWhere((p) => p.stored == s);
}

enum ParentingStyle { authoritative, authoritarian, permissive, neglectful }

class Item {
  const Item({
    required this.id,
    required this.dimension,
    required this.reverse,
    required this.text,
  });

  final String id;
  final Dimension dimension;
  final bool reverse;

  /// `child_view` texts contain `{parent}`; see [textFor].
  final String text;

  String textFor(String parentName) => text.replaceAll('{parent}', parentName);

  factory Item.fromJson(Map<String, dynamic> j) => Item(
    id: j['id'] as String,
    dimension: Dimension.values.byName(j['dimension'] as String),
    reverse: j['reverse'] as bool,
    text: j['text'] as String,
  );
}

class AssessmentContent {
  const AssessmentContent({
    required this.version,
    required this.scale,
    required this.forms,
  });

  /// `major.minor`; compare only within one major (docs/ASSESSMENT.md).
  final String version;

  /// Labels for answers 1..5.
  final List<String> scale;
  final Map<Perspective, List<Item>> forms;

  factory AssessmentContent.fromJson(Map<String, dynamic> j) {
    final forms = j['forms'] as Map<String, dynamic>;
    return AssessmentContent(
      version: j['contentVersion'] as String,
      scale: (j['scale'] as List).cast<String>(),
      forms: {
        for (final p in Perspective.values)
          p: [
            for (final i in forms[p.formKey] as List)
              Item.fromJson(i as Map<String, dynamic>),
          ],
      },
    );
  }
}

class Advice {
  const Advice({
    required this.id,
    required this.role,
    required this.style,
    required this.tags,
    required this.scenario,
    required this.guidance,
    required this.challenge,
  });

  final String id;
  final Role role;
  final ParentingStyle style;
  final List<String> tags;
  final String scenario;
  final String guidance;

  /// The one-week action used when a Challenge starts from this card (M5).
  final String challenge;

  factory Advice.fromJson(Map<String, dynamic> j) => Advice(
    id: j['id'] as String,
    role: Role.values.byName(j['role'] as String),
    style: ParentingStyle.values.byName(j['style'] as String),
    tags: (j['tags'] as List).cast<String>(),
    scenario: j['scenario'] as String,
    guidance: j['guidance'] as String,
    challenge: j['challenge'] as String,
  );
}

class AdviceLibrary {
  const AdviceLibrary({required this.version, required this.items});

  final String version;
  final List<Advice> items;

  static const tags = [
    'bedtime',
    'screens',
    'study',
    'friends',
    'chores',
    'emotions',
    'money',
    'respect',
  ];

  factory AdviceLibrary.fromJson(Map<String, dynamic> j) => AdviceLibrary(
    version: j['contentVersion'] as String,
    items: [
      for (final a in j['advice'] as List)
        Advice.fromJson(a as Map<String, dynamic>),
    ],
  );
}

/// A saved Assessment: scores only. Item answers stay private to the rater.
class Assessment {
  const Assessment({
    required this.id,
    required this.raterId,
    required this.subjectParentId,
    required this.perspective,
    required this.warmth,
    required this.demandingness,
    required this.style,
    required this.contentVersion,
    required this.createdAt,
  });

  final String id;
  final String raterId;
  final String subjectParentId;
  final Perspective perspective;
  final int warmth;
  final int demandingness;
  final ParentingStyle style;
  final String contentVersion;
  final DateTime createdAt;

  String get majorVersion => contentVersion.split('.').first;
}
