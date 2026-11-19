import 'package:flutter/foundation.dart';

import '../../../../app/session.dart';
import '../../../../data/repositories/assessment_repository.dart';
import '../../../../data/repositories/content_repository.dart';
import '../../../../domain/assessment/scoring.dart';
import '../../../../domain/models/assessment.dart';
import '../../../../utils/result.dart';

enum AssessmentStep { loading, intro, answering, saving, result }

/// One Assessment run: intro → one Item per screen → saved result.
/// A Parent rating themselves when [subjectParentId] is the user, otherwise a
/// Child rating that Parent.
class AssessmentViewModel extends ChangeNotifier {
  AssessmentViewModel({
    required this._session,
    required this._content,
    required this._assessments,
    required this.subjectParentId,
    required this.subjectName,
  }) {
    _load();
  }

  final Session _session;
  final ContentRepository _content;
  final AssessmentRepository _assessments;
  final String subjectParentId;
  final String subjectName;

  AssessmentStep _step = AssessmentStep.loading;
  AssessmentStep get step => _step;

  late AssessmentContent _form;
  List<Item> _items = const [];
  List<Item> get items => _items;
  List<String> get scale => _form.scale;

  final Map<String, int> _answers = {};
  int? answerFor(Item item) => _answers[item.id];
  bool get hasDraft => _answers.isNotEmpty;

  int _index = 0;
  int get index => _index;
  Item get current => _items[_index];
  bool get isLast => _index == _items.length - 1;
  bool get allAnswered => _answers.length == _items.length;

  Scores? _scores;
  Scores? get scores => _scores;

  List<Advice> _advice = const [];
  List<Advice> get advice => _advice;

  AppError? _error;
  AppError? get error => _error;

  String get _uid => _session.profile!.uid;
  Perspective get perspective =>
      subjectParentId == _uid ? Perspective.self : Perspective.childView;

  String itemText(Item item) => item.textFor(subjectName);

  Future<void> _load() async {
    final locale = _session.profile!.locale;
    _form = await _content.assessment(locale);
    _items = _form.forms[perspective]!;
    final draft = await _assessments.loadDraft(_uid, subjectParentId);
    final ids = {for (final i in _items) i.id};
    _answers.addAll({
      for (final e in draft.entries)
        if (ids.contains(e.key)) e.key: e.value,
    });
    _index = _items.indexWhere((i) => !_answers.containsKey(i.id));
    if (_index < 0) _index = _items.length - 1;
    _step = AssessmentStep.intro;
    notifyListeners();
  }

  void start() {
    _step = AssessmentStep.answering;
    notifyListeners();
  }

  /// Records [value] (1..5) and moves on, except on the last Item.
  void answer(int value) {
    _answers[current.id] = value;
    _assessments.saveDraft(_uid, subjectParentId, Map.of(_answers));
    if (!isLast) _index++;
    notifyListeners();
  }

  void back() {
    if (_index == 0) return;
    _index--;
    notifyListeners();
  }

  Future<void> submit() async {
    final profile = _session.profile!;
    final scores = score(_items, _answers);
    _step = AssessmentStep.saving;
    _error = null;
    notifyListeners();
    final result = await _assessments.save(
      fid: profile.familyId!,
      uid: profile.uid,
      perspective: perspective,
      subjectParentId: subjectParentId,
      answers: Map.of(_answers),
      scores: scores,
      contentVersion: _form.version,
    );
    if (result case Err(:final error)) {
      _error = error;
      _step = AssessmentStep.answering;
      notifyListeners();
      return;
    }
    await _assessments.clearDraft(profile.uid, subjectParentId);
    final library = await _content.advice(profile.locale);
    _advice = library.items
        .where((a) => a.role == profile.role && a.style == scores.style)
        .take(3)
        .toList();
    _scores = scores;
    _step = AssessmentStep.result;
    notifyListeners();
  }
}
