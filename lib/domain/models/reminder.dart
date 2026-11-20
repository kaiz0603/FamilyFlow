import 'challenge.dart';

/// Opt-in device Reminders (PRD F8.3). Both off by default.
class ReminderSettings {
  const ReminderSettings({
    this.weeklyOn = false,
    this.weekday = DateTime.sunday,
    this.weeklyMinutes = 19 * 60,
    this.dailyOn = false,
    this.dailyMinutes = 19 * 60,
  });

  final bool weeklyOn;

  /// `DateTime.monday` (1) … `DateTime.sunday` (7).
  final int weekday;

  /// Minutes after local midnight.
  final int weeklyMinutes;
  final bool dailyOn;
  final int dailyMinutes;

  ReminderSettings copyWith({
    bool? weeklyOn,
    int? weekday,
    int? weeklyMinutes,
    bool? dailyOn,
    int? dailyMinutes,
  }) => ReminderSettings(
    weeklyOn: weeklyOn ?? this.weeklyOn,
    weekday: weekday ?? this.weekday,
    weeklyMinutes: weeklyMinutes ?? this.weeklyMinutes,
    dailyOn: dailyOn ?? this.dailyOn,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
  );
}

enum ReminderKind { weekly, daily }

/// One notification to schedule. [at] is a local wall-clock time; a weekly
/// Reminder repeats on the same weekday and time, a daily one fires once.
class PlannedReminder {
  const PlannedReminder(this.id, this.kind, this.at);

  final int id;
  final ReminderKind kind;
  final DateTime at;

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.id == id &&
      other.kind == kind &&
      other.at == at;

  @override
  int get hashCode => Object.hash(id, kind, at);

  @override
  String toString() => 'PlannedReminder($id, $kind, $at)';
}

const weeklyReminderId = 1;
const dailyReminderIdBase = 100;

/// Which Reminders should exist, given the settings and the Family's newest
/// [challenge]. Daily Check-in Reminders are one-shots for each remaining day
/// of the week the user has not checked in on, so none outlive the Challenge.
List<PlannedReminder> planReminders(
  ReminderSettings s, {
  required String uid,
  required Challenge? challenge,
  required DateTime now,
}) {
  final out = <PlannedReminder>[];
  if (s.weeklyOn) {
    final base = DateTime(
      now.year,
      now.month,
      now.day,
      s.weeklyMinutes ~/ 60,
      s.weeklyMinutes % 60,
    );
    final ahead = (s.weekday - now.weekday) % 7;
    var at = DateTime(
      base.year,
      base.month,
      base.day + ahead,
      base.hour,
      base.minute,
    );
    if (!at.isAfter(now)) {
      at = DateTime(at.year, at.month, at.day + 7, at.hour, at.minute);
    }
    out.add(PlannedReminder(weeklyReminderId, ReminderKind.weekly, at));
  }
  final today = localDate(now);
  if (s.dailyOn &&
      challenge != null &&
      !challenge.isOver(today) &&
      challenge.participants.contains(uid)) {
    final days = challenge.days;
    for (var i = 0; i < days.length; i++) {
      final d = DateTime.parse(days[i]);
      final at = DateTime(
        d.year,
        d.month,
        d.day,
        s.dailyMinutes ~/ 60,
        s.dailyMinutes % 60,
      );
      if (at.isAfter(now) && !challenge.checkedIn(uid, days[i])) {
        out.add(
          PlannedReminder(dailyReminderIdBase + i, ReminderKind.daily, at),
        );
      }
    }
  }
  return out;
}
