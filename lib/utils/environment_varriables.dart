class EnvVarriables {
  static const String env = String.fromEnvironment(
    'DEFINE_ENV',
    defaultValue: 'live',
  );
}
