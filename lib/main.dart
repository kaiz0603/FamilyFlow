import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'config/env.dart';
import 'config/firebase_options.dart';
import 'data/repositories/assessment_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/challenge_repository.dart';
import 'data/repositories/content_repository.dart';
import 'data/repositories/family_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/reminder_repository.dart';
import 'data/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptionsFor(Env.current));
  if (Env.current == Env.dev && Env.useEmulator) {
    // The Android emulator reaches the host machine at 10.0.2.2.
    final host = Env.emulatorHost.isNotEmpty
        ? Env.emulatorHost
        : defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }
  runApp(
    FamilyFlowApp(
      auth: AuthRepository(FirebaseAuth.instance),
      profiles: ProfileRepository(FirebaseFirestore.instance),
      families: FamilyRepository(FirebaseFirestore.instance),
      assessments: AssessmentRepository(FirebaseFirestore.instance),
      challenges: ChallengeRepository(FirebaseFirestore.instance),
      content: ContentRepository(),
      reminders: ReminderRepository(LocalNotificationService()),
    ),
  );
}
