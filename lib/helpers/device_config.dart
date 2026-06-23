import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class DeviceConfig {
  static bool isMobile = false;
  static bool isTablet = false;
  static bool isWeb = false;
  static bool isLandscape = false;

  static void init(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Check if the app is running on Web
    isWeb = kIsWeb;

    // Detect landscape mode
    isLandscape = width > height;

    // Detect Mobile and Tablet (only for non-Web)
    if (!isWeb) {
      isMobile = width < 600; // Mobile: Width < 600
      isTablet = width >= 600 && width < 1200; // Tablet: Width 600 - 1200
    } else {
      // If running on Web, set isTablet based on screen width
      isTablet = width >= 600 && width < 1200;
      isMobile = width < 600;
    }
  }
}
