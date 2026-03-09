import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holy_quran/firebase_options.dart';
import 'package:holy_quran/main.config.dart';
import 'package:holy_quran/routes/routes_manager.dart';
import 'package:holy_quran/screens/surah_learning_path/surah_learning_path_screen.dart'; // import routeObserver
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
  final savedLanguageCode = SharedPrefrencesHelper.getString(
    key: SharedPrefrencesHelper.languageCodeKey,
  );
  await _initializeGoogleSignIn();

  runApp(
    MyApp(
      initialLocale: savedLanguageCode != null
          ? Locale(savedLanguageCode)
          : null,
    ),
  );
}

Future<void> _initializeGoogleSignIn() async {
  if (Platform.isIOS) {
    await GoogleSignIn.instance.initialize(
      clientId:
          '432662593937-evm8h55age04hnna8fku0doh21eks2n7.apps.googleusercontent.com',
    );
  } else {
    await GoogleSignIn.instance.initialize();
  }
}

class MyApp extends StatelessWidget {
  final Locale? initialLocale;
  const MyApp({super.key, this.initialLocale});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          locale: initialLocale,
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
          navigatorObservers: [routeObserver],
          initialRoute: RoutesManager.splashRoute,
          onGenerateRoute: RouteGenetator.onGenerateRoute,
        );
      },
    );
  }
}
