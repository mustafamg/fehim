import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:holy_quran/firebase_options.dart';
import 'package:holy_quran/main.config.dart';
import 'package:holy_quran/routes/routes_manager.dart';
import 'package:holy_quran/utils/helper/shared_pref.dart';
import 'package:holy_quran/values/theme_manager.dart';
import 'package:injectable/injectable.dart';
import 'generated/l10n.dart';
final getIt = GetIt.instance;
@InjectableInit(
  initializerName: 'init', 
  preferRelativeImports: true, 
  asExtension: true, 
)
void configureDependencies() => getIt.init();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  configureDependencies();
  await ScreenUtil.ensureScreenSize();
  await SharedPrefrencesHelper.setUpShared();
  
  
  
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          title: 'Holy Quran',
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.getApplicationLightTheme(),
          themeMode: ThemeMode.light,
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaler: TextScaler.noScaling),
              child: SafeArea(top: false, bottom: true, child: child!),
            );
          },
          initialRoute: RoutesManager.splashRoute,
          onGenerateRoute: RouteGenetator.onGenerateRoute,
        );
      },
    );
  }
}
