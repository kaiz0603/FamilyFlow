/// A one-week Family Challenge started from an Advice card (PRD F7).
/// Dates are the creator's local calendar dates as `YYYY-MM-DD`.
class Challenge {
  const Challenge({
    required this.id,
    required this.adviceId,
    required this.title,
    required this.createdBy,
    required this.participants,
    required this.startDate,
    required this.endDate,
    required this.finished,
    required this.checkIns,
  });

  final String id;
  final String adviceId;
  final String title;
  final String createdBy;
  final List<String> participants;
  final String startDate;
  final String endDate;

  /// Stored `status == "finished"`. See [isOver] for the derived state.
  final bool finished;
  final Map<String, List<String>> checkIns;

  static const length = 7;

  /// The seven dates of the week, start first.
  List<String> get days => [
    for (var i = 0; i < length; i++) addDays(startDate, i),
  ];

  /// Finished, or the week has passed on [today] (status not yet written).
  bool isOver(String today) => finished || today.compareTo(endDate) > 0;

  bool checkedIn(String uid, String day) =>
      checkIns[uid]?.contains(day) ?? false;

  int countFor(String uid) => checkIns[uid]?.length ?? 0;

  bool canCheckIn(String uid, String today) =>
      !isOver(today) &&
      participants.contains(uid) &&
      today.compareTo(startDate) >= 0 &&
      !checkedIn(uid, today);
}

enum ActivityType {
  memberJoined('member_joined'),
  memberLeft('member_left'),
  assessmentDone('assessment_done'),
  challengeStarted('challenge_started'),
  challengeFinished('challenge_finished');

  const ActivityType(this.stored);
  final String stored;

  static ActivityType? fromStored(String s) =>
      values.where((t) => t.stored == s).firstOrNull;
}

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.type,
    required this.actorId,
    required this.createdAt,
  });

  final String id;
  final ActivityType type;
  final String actorId;
  final DateTime createdAt;
}

/// `YYYY-MM-DD` of [t] in its own (local) time zone.
String localDate(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-'
    '${t.month.toString().padLeft(2, '0')}-'
    '${t.day.toString().padLeft(2, '0')}';

/// Calendar arithmetic in UTC so daylight-saving changes cannot skip a day.
String addDays(String date, int days) {
  final d = DateTime.parse('${date}T00:00:00Z').add(Duration(days: days));
  return d.toIso8601String().substring(0, 10);
}
