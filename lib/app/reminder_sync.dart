import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../data/repositories/challenge_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../domain/models/challenge.dart';
import '../l10n/app_localizations.dart';
import 'session.dart';

/// Keeps the scheduled notifications in step with the signed-in user, their
/// settings and the Family's Challenge. Lives for the whole app, so Reminders
/// follow a Challenge that starts or ends while Home is not on screen.
class ReminderSync {
  ReminderSync({
    required this._session,
    required this._challenges,
    required this._reminders,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    _session.addListener(_onSession);
    _onSession();
  }

  final Session _session;
  final ChallengeRepository _challenges;
  final ReminderRepository _reminders;
  final DateTime Function() _now;

  StreamSubscription<Challenge?>? _sub;
  Challenge? _challenge;
  String? _key;
  Future<void> _queue = Future.value();

  void _onSession() {
    final p = _session.profile;
    final status = _session.status;
    // Ignore the loading phase: Reminders must survive a cold start.
    if (status == SessionStatus.signedOut) {
      _follow(null, 'out');
    } else if (status == SessionStatus.ready && p != null) {
      _follow(p.familyId, '${p.uid}|${p.familyId}|${p.locale}');
    }
  }

  void _follow(String? fid, String key) {
    if (key == _key) return;
    _key = key;
    _sub?.cancel();
    _sub = null;
    _challenge = null;
    if (fid == null) {
      refresh();
    } else {
      // The first event runs refresh(); later ones are Challenge changes.
      _sub = _challenges.watchCurrent(fid).listen((c) {
        _challenge = c;
        refresh();
      });
    }
  }

  /// Reschedule now. Call after the settings change.
  Future<void> refresh() =>
      _queue = _queue.then((_) => _run()).catchError((Object e) {
        debugPrint('Reminder sync failed: $e');
      });

  Future<void> _run() async {
    final p = _session.profile;
    if (_session.status == SessionStatus.signedOut) {
      return _reminders.cancelAll();
    }
    if (p == null) return;
    final l = lookupAppLocalizations(Locale(p.locale));
    await _reminders.apply(
      p.uid,
      ReminderTexts(
        title: l.appTitle,
        weeklyBody: l.reminderWeeklyBody,
        dailyBody: l.reminderDailyBody,
      ),
      challenge: _challenge,
      now: _now(),
    );
  }

  void dispose() {
    _session.removeListener(_onSession);
    _sub?.cancel();
  }
}
