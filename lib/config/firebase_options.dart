import 'package:firebase_core/firebase_core.dart';

import 'env.dart';
import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;

/// Firebase options per [Env]. The generated files come from `flutterfire configure`
/// (see docs/RELEASE.md). On the emulators dev keeps the `demo-familyflow` project,
/// which the emulator config, seed scripts and rules tests use.
FirebaseOptions firebaseOptionsFor(Env env) => switch (env) {
  Env.dev when Env.useEmulator => const FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-familyflow',
  ),
  Env.dev => dev.DefaultFirebaseOptions.currentPlatform,
  Env.prod => prod.DefaultFirebaseOptions.currentPlatform,
};
