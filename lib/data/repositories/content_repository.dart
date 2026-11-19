import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/assessment.dart';

/// The Items and Advice shipped in assets/content (docs/ASSESSMENT.md).
/// Parsed once per language and kept in memory.
class ContentRepository {
  ContentRepository([AssetBundle? bundle]) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final _assessments = <String, Future<AssessmentContent>>{};
  final _advice = <String, Future<AdviceLibrary>>{};

  static String _lang(String locale) => locale == 'zh' ? 'zh' : 'en';

  Future<AssessmentContent> assessment(String locale) =>
      _assessments.putIfAbsent(
        _lang(locale),
        () async => AssessmentContent.fromJson(
          await _json('assets/content/assessment.${_lang(locale)}.json'),
        ),
      );

  Future<AdviceLibrary> advice(String locale) => _advice.putIfAbsent(
    _lang(locale),
    () async => AdviceLibrary.fromJson(
      await _json('assets/content/advice.${_lang(locale)}.json'),
    ),
  );

  Future<Map<String, dynamic>> _json(String path) async =>
      jsonDecode(await _bundle.loadString(path)) as Map<String, dynamic>;
}
