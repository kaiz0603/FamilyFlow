import 'package:familyflow/domain/assessment/scoring.dart';
import 'package:familyflow/domain/models/assessment.dart';
import 'package:flutter_test/flutter_test.dart';

/// 12 warmth + 12 demandingness items, the last 4 of each reverse-keyed.
final items = [
  for (final d in Dimension.values)
    for (var i = 1; i <= 12; i++)
      Item(id: '${d.name[0]}$i', dimension: d, reverse: i > 8, text: ''),
];

Map<String, int> answersWhere(int Function(Item) value) => {
  for (final item in items) item.id: value(item),
};

void main() {
  test('all 5 on normal items and 1 on reverse items is 100/100', () {
    final s = score(items, answersWhere((i) => i.reverse ? 1 : 5));
    expect((s.warmth, s.demandingness), (100, 100));
    expect(s.style, ParentingStyle.authoritative);
  });

  test('the opposite is 0/0, neglectful', () {
    final s = score(items, answersWhere((i) => i.reverse ? 5 : 1));
    expect((s.warmth, s.demandingness), (0, 0));
    expect(s.style, ParentingStyle.neglectful);
  });

  test('all "neither" is exactly 50/50, which counts as high', () {
    final s = score(items, answersWhere((_) => 3));
    expect((s.warmth, s.demandingness), (50, 50));
    expect(s.style, ParentingStyle.authoritative);
  });

  test('reverse items are flipped: all 5 everywhere is not 100', () {
    final s = score(items, answersWhere((_) => 5));
    // 8 items at 5 and 4 flipped to 1: mean 11/3 → round((11/3 - 1) / 4 * 100) = 67.
    expect((s.warmth, s.demandingness), (67, 67));
  });

  test('each quadrant', () {
    int high(Item i) => i.reverse ? 2 : 4; // 75
    int low(Item i) => i.reverse ? 4 : 2; // 25
    final cases = {
      ParentingStyle.authoritarian: (Dimension.demandingness, high, low),
      ParentingStyle.permissive: (Dimension.warmth, high, low),
    };
    for (final MapEntry(key: style, value: (highDim, hi, lo))
        in cases.entries) {
      final s = score(
        items,
        answersWhere((i) => i.dimension == highDim ? hi(i) : lo(i)),
      );
      expect(s.style, style);
    }
    expect(styleFor(49, 50), ParentingStyle.authoritarian);
    expect(styleFor(50, 49), ParentingStyle.permissive);
    expect(styleFor(49, 49), ParentingStyle.neglectful);
  });

  test('missing or out-of-range answers are rejected', () {
    final complete = answersWhere((_) => 3);
    expect(
      () => score(items, {...complete}..remove('w1')),
      throwsArgumentError,
    );
    expect(() => score(items, {...complete, 'w1': 6}), throwsArgumentError);
    expect(() => score(items, {...complete, 'w1': 0}), throwsArgumentError);
  });

  test('perception gap bands', () {
    expect(gapBand(5), GapBand.same);
    expect(gapBand(-9), GapBand.same);
    expect(gapBand(10), GapBand.some);
    expect(gapBand(-24), GapBand.some);
    expect(gapBand(25), GapBand.large);
  });
}
