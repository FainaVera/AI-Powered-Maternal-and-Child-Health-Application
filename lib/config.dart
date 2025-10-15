// Backend configuration
class Config {
  // Use 10.0.2.2 for Android emulator, or your actual device IP for real device
  static const String baseUrl = 'http://10.0.2.2:3000';
  // static const String baseUrl = 'http://x.x.x.x:3000';

  static const String loginUrl = '$baseUrl/login';
  static const String signupUrl = '$baseUrl/signup';
  static const String childUrl = '$baseUrl/child';
  static const String pregnantUrl = '$baseUrl/pregnant';
  static const String aiSuggestionsUrl = '$baseUrl/ai/suggestions';
}