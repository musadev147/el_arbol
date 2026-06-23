import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static Future<bool> shouldShow(String role) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool("onboard_$role") ?? false);
  }

  static Future<void> markDone(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboard_$role", true);
  }
}
