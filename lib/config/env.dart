/// Build-time environment, chosen with `--dart-define=ENV=dev|prod`.
enum Env {
  dev,
  prod;

  static final Env current = Env.values.byName(
    const String.fromEnvironment('ENV', defaultValue: 'dev'),
  );

  /// Dev talks to the local emulators by default; `--dart-define=USE_EMULATOR=false` uses the real dev project.
  static const bool useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: true,
  );

  /// Overrides the emulator host, e.g. `localhost` on a USB phone with `adb reverse`.
  static const String emulatorHost = String.fromEnvironment('EMULATOR_HOST');
}
