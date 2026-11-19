import 'dart:convert';
import 'dart:io';

import 'package:familyflow/domain/models/assessment.dart';
import 'package:familyflow/domain/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the shipped content files (docs/ASSESSMENT.md "Review before public release").
Map<String, dynamic> load(String name) =>
    jsonDecode(File('assets/content/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  final assessment = {
    for (final lang in ['zh', 'en'])
      lang: AssessmentContent.fromJson(load('assessment.$lang.json')),
  };
  final advice = {
    for (final lang in ['zh', 'en'])
      lang: AdviceLibrary.fromJson(load('advice.$lang.json')),
  };

  test('zh and en share one content version', () {
    final versions = {
      for (final a in assessment.values) a.version,
      for (final a in advice.values) a.version,
    };
    expect(versions, hasLength(1));
  });

  for (final perspective in Perspective.values) {
    test(
      '${perspective.name}: 12 + 12 items, 4 reverse-keyed each, same ids in zh/en',
      () {
        final zh = assessment['zh']!.forms[perspective]!;
        final en = assessment['en']!.forms[perspective]!;
        expect(
          zh.map((i) => (i.id, i.dimension, i.reverse)),
          en.map((i) => (i.id, i.dimension, i.reverse)),
        );
        for (final d in Dimension.values) {
          final ofDim = zh.where((i) => i.dimension == d);
          expect(ofDim, hasLength(12), reason: d.name);
          expect(ofDim.where((i) => i.reverse), hasLength(4), reason: d.name);
        }
        expect(zh.map((i) => i.id).toSet(), hasLength(24));
      },
    );
  }

  test('the two forms are parallel (same item ids)', () {
    final a = assessment['zh']!;
    expect(
      a.forms[Perspective.self]!.map((i) => i.id),
      a.forms[Perspective.childView]!.map((i) => i.id),
    );
  });

  test('every child_view item names the parent', () {
    for (final a in assessment.values) {
      for (final item in a.forms[Perspective.childView]!) {
        expect(item.text, contains('{parent}'), reason: item.id);
      }
    }
  });

  test('advice: same ids in zh/en, unique, known tags', () {
    final zhIds = advice['zh']!.items.map((a) => a.id).toList();
    expect(zhIds.toSet(), hasLength(zhIds.length));
    expect(advice['en']!.items.map((a) => a.id).toSet(), zhIds.toSet());
    for (final a in advice['zh']!.items) {
      expect(AdviceLibrary.tags, containsAll(a.tags), reason: a.id);
    }
  });

  test('advice covers every tag for every role and style', () {
    for (final role in Role.values) {
      for (final style in ParentingStyle.values) {
        final cards = advice['zh']!.items.where(
          (a) => a.role == role && a.style == style,
        );
        expect(
          cards.expand((a) => a.tags).toSet(),
          AdviceLibrary.tags.toSet(),
          reason: '${role.name}/${style.name}',
        );
      }
    }
  });
}
