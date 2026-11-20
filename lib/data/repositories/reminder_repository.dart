import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/challenge.dart';
import '../../domain/models/reminder.dart';
import '../services/notification_service.dart';

/// Notification wording, already localized by the caller.
class ReminderTexts {
  const ReminderTexts({
    required this.title,
    required this.weeklyBody,
    required this.dailyBody,
  });

  final String title;
  final String weeklyBody;
  final String dailyBody;
}

/// Reminder settings (device only, per user, docs/PRIVACY.md) and the
/// notifications they produce.
class ReminderRepository {
  ReminderRepository(this._service, [Future<SharedPreferences>? prefs])
    : _prefs = prefs ?? SharedPreferences.getInstance();

  final NotificationService _service;
  final Future<SharedPreferences> _prefs;

  static String _key(String uid, String field) => 'reminder:$uid:$field';

  Future<ReminderSettings> load(String uid) async {
    final p = await _prefs;
    const d = ReminderSettings();
    return ReminderSettings(
      weeklyOn: p.getBool(_key(uid, 'weeklyOn')) ?? d.weeklyOn,
      weekday: p.getInt(_key(uid, 'weekday')) ?? d.weekday,
      weeklyMinutes: p.getInt(_key(uid, 'weeklyMinutes')) ?? d.weeklyMinutes,
      dailyOn: p.getBool(_key(uid, 'dailyOn')) ?? d.dailyOn,
      dailyMinutes: p.getInt(_key(uid, 'dailyMinutes')) ?? d.dailyMinutes,
    );
  }

  Future<void> save(String uid, ReminderSettings s) async {
    final p = await _prefs;
    await p.setBool(_key(uid, 'weeklyOn'), s.weeklyOn);
    await p.setInt(_key(uid, 'weekday'), s.weekday);
    await p.setInt(_key(uid, 'weeklyMinutes'), s.weeklyMinutes);
    await p.setBool(_key(uid, 'dailyOn'), s.dailyOn);
    await p.setInt(_key(uid, 'dailyMinutes'), s.dailyMinutes);
  }

  /// Account deletion: forget this user's settings.
  Future<void> clear(String uid) async {
    final p = await _prefs;
    for (final k in p.getKeys().where((k) => k.startsWith('reminder:$uid:'))) {
      await p.remove(k);
    }
  }

  Future<bool> requestPermission() => _service.requestPermission();

  /// Replaces every scheduled notification with the ones [planReminders] wants.
  Future<void> apply(
    String uid,
    ReminderTexts texts, {
    required Challenge? challenge,
    required DateTime now,
  }) async {
    await _service.cancelAll();
    final plan = planReminders(
      await load(uid),
      uid: uid,
      challenge: challenge,
      now: now,
    );
    for (final r in plan) {
      final weekly = r.kind == ReminderKind.weekly;
      await _service.schedule(
        id: r.id,
        at: r.at,
        title: texts.title,
        body: weekly ? texts.weeklyBody : texts.dailyBody,
        weekly: weekly,
      );
    }
  }

  Future<void> cancelAll() => _service.cancelAll();
}
