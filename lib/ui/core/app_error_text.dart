import '../../l10n/app_localizations.dart';
import '../../utils/result.dart';

extension AppErrorText on AppError {
  String message(AppLocalizations l) => switch (this) {
    AppError.network => l.errNetwork,
    AppError.invalidCredentials => l.errInvalidCredentials,
    AppError.emailInUse => l.errEmailInUse,
    AppError.weakPassword => l.errWeakPassword,
    AppError.invalidEmail => l.errInvalidEmail,
    AppError.tooManyRequests => l.errTooManyRequests,
    AppError.requiresRecentLogin => l.errRequiresRecentLogin,
    AppError.permissionDenied => l.errPermissionDenied,
    AppError.invalidInviteCode => l.errInvalidInviteCode,
    AppError.challengeActive => l.errChallengeActive,
    AppError.unknown => l.errUnknown,
  };
}
