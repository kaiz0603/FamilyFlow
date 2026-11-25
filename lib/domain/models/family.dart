import 'user_profile.dart';

class Family {
  const Family({required this.id, required this.name, required this.createdBy});

  final String id;
  final String name;
  final String createdBy;

  static const maxNameLength = 40;
}

class Member {
  const Member({
    required this.uid,
    required this.role,
    required this.displayName,
  });

  final String uid;
  final Role role;
  final String displayName;
}

enum JoinStatus { pending, approved, rejected }

class JoinRequest {
  const JoinRequest({
    required this.uid,
    required this.role,
    required this.displayName,
    required this.status,
  });

  final String uid;
  final Role role;
  final String displayName;
  final JoinStatus status;
}

class Invite {
  const Invite({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;

  /// No 0/O/1/I, so codes survive being read aloud or copied by hand.
  static const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const length = 6;
  static const lifetime = Duration(days: 7);

  static String normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'\s'), '');

  static bool isWellFormed(String code) =>
      code.length == length && code.split('').every(alphabet.contains);
}
