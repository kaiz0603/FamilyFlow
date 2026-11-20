// firebase_auth re-exports FirebaseException from firebase_core.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Outcome of a repository command. Views never see raw exceptions.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;
}

/// The small set of failures the UI knows how to explain (ARB key per value).
enum AppError {
  network,
  invalidCredentials,
  emailInUse,
  weakPassword,
  invalidEmail,
  tooManyRequests,
  requiresRecentLogin,
  permissionDenied,
  invalidInviteCode,
  challengeActive,
  unknown;

  static AppError from(Object e) => switch (e) {
    AppException(:final error) => error,
    FirebaseAuthException(:final code) => switch (code) {
      'network-request-failed' => network,
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'user-disabled' => invalidCredentials,
      'email-already-in-use' => emailInUse,
      'weak-password' => weakPassword,
      'invalid-email' => invalidEmail,
      'too-many-requests' => tooManyRequests,
      'requires-recent-login' => requiresRecentLogin,
      _ => unknown,
    },
    FirebaseException(:final code) => switch (code) {
      'unavailable' => network,
      'permission-denied' => permissionDenied,
      _ => unknown,
    },
    _ => unknown,
  };
}

/// Thrown inside a repository operation to fail it with a known [AppError].
class AppException implements Exception {
  const AppException(this.error);
  final AppError error;
}

/// Runs [op] and turns any thrown error into an [Err].
Future<Result<T>> guard<T>(Future<T> Function() op) async {
  try {
    return Ok(await op());
  } catch (e) {
    final error = AppError.from(e);
    // The UI only says "something went wrong"; keep the cause visible in dev.
    if (error == AppError.unknown && kDebugMode) {
      debugPrint('AppError.unknown: $e');
    }
    return Err(error);
  }
}
