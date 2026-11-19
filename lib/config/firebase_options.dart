import 'package:firebase_core/firebase_core.dart';

import 'env.dart';

/// Firebase options per [Env].
///
/// shortcut: dev uses the emulator-only `demo-familyflow` project and prod is not
/// configured yet. Replace both with `flutterfire configure` output at M1.
FirebaseOptions firebaseOptionsFor(Env env) => switch (env) {
  Env.dev => const FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-familyflow',
  ),
  Env.prod => throw UnsupportedError(
    'Prod Firebase is not configured yet. Run flutterfire configure (M1).',
  ),
};
