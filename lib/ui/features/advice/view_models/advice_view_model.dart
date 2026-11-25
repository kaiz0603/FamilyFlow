import 'package:flutter/foundation.dart';

import '../../../../app/session.dart';
import '../../../../data/repositories/content_repository.dart';
import '../../../../domain/models/assessment.dart';

/// The Advice library for the user's Role, filtered by style and topic (PRD F4).
class AdviceViewModel extends ChangeNotifier {
  AdviceViewModel({
    required this._session,
    required this._content,
    this._style,
  }) {
    _load();
  }

  final Session _session;
  final ContentRepository _content;

  List<Advice> _all = const [];
  bool _loaded = false;
  bool get loaded => _loaded;

  ParentingStyle? _style;
  ParentingStyle? get style => _style;

  String? _tag;
  String? get tag => _tag;

  List<Advice> get visible => [
    for (final a in _all)
      if ((_style == null || a.style == _style) &&
          (_tag == null || a.tags.contains(_tag)))
        a,
  ];

  Future<void> _load() async {
    final profile = _session.profile!;
    final library = await _content.advice(profile.locale);
    _all = library.items.where((a) => a.role == profile.role).toList();
    _loaded = true;
    notifyListeners();
  }

  void filterStyle(ParentingStyle? s) {
    _style = s;
    notifyListeners();
  }

  void filterTag(String? t) {
    _tag = t;
    notifyListeners();
  }
}
