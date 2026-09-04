import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';

import 'helpers/di.dart';
import 'helpers/helper_methods.dart';
import 'helpers/navigation_service.dart';
import 'networks/dio/dio.dart';
import 'constants/custom_theme.dart';
import 'helpers/register_provider.dart';
import 'splash.dart';
import 'route/app_pages.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure high-performance image cache for instant loading
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 250 << 20; // 250 MB

  await GetStorage.init();
  diSetup();
  initiInternetChecker();
  DioSingleton.instance.create();
  configLoading();
  runApp(MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(seconds: 3)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 42.0
    ..radius = 16.0
    ..maskType = EasyLoadingMaskType.black
    ..toastPosition = EasyLoadingToastPosition.center
    ..backgroundColor = const Color(0xFF00694C)
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..progressColor = Colors.white
    ..boxShadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ]
    ..textStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    )
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    configLoading();
  }

  @override
  Widget build(BuildContext context) {
    configLoading();
    rotation();
    setInitValue();
    return MultiProvider(
      providers: providers,
      child: AnimateIfVisibleWrapper(
        showItemInterval: const Duration(milliseconds: 150),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return const UtillScreenMobile();
          },
        ),
      ),
    );
  }
}

class UtillScreenMobile extends StatelessWidget {
  const UtillScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          showPerformanceOverlay: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF00694C),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color(0xFF00694C),
              secondary: const Color(0xFF00694C),
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Color(0xFF00694C),
              circularTrackColor: Colors.transparent,
              linearTrackColor: Colors.transparent,
              refreshBackgroundColor: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark, // For Android
                statusBarBrightness: Brightness.light,    // For iOS
              ),
            ),
            primarySwatch: CustomTheme.kToDark,
            scaffoldBackgroundColor: AppColors.white,
            useMaterial3: false,
          ),
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          // Register the shared observer so RouteAware.didPopNext fires on
          // every screen that subscribes (e.g. AstTenantListScreen).
          navigatorObservers: [routeObserver],
          home: const SplashScreen(),

          builder: EasyLoading.init(),
        );
      },
    );
  }
}
