import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/demo/demo_page.dart';
import 'package:flutter_deer/home/splash_page.dart';
import 'package:flutter_deer/net/dio_utils.dart';
import 'package:flutter_deer/net/intercept.dart';
import 'package:flutter_deer/res/constant.dart';
import 'package:flutter_deer/routers/not_found_page.dart';
import 'package:flutter_deer/routers/routers.dart';
import 'package:flutter_deer/setting/provider/locale_provider.dart';
import 'package:flutter_deer/setting/provider/theme_provider.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:flutter_deer/util/handle_error_utils.dart';
import 'package:flutter_deer/util/log_utils.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_gen/gen_l10n/deer_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:sp_util/sp_util.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
//  debugProfileBuildsEnabled = true;
//  debugPaintLayerBordersEnabled = true;
//  debugProfilePaintsEnabled = true;
//  debugRepaintRainbowEnabled = true;

  /// Make sure initialization is complete
  WidgetsFlutterBinding.ensureInitialized();

  if (Device.isDesktop) {
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      /// Hide the title bar and action buttons
      // await windowManager.setTitleBarStyle(
      //   TitleBarStyle.hidden,
      //   windowButtonVisibility: false,
      // );
      /// Set the desktop window size
      await windowManager.setSize(const Size(400, 800));
      await windowManager.setMinimumSize(const Size(400, 800));

      /// center display
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(false);
      await windowManager.setSkipTaskbar(false);
    });
  }

  /// Remove the "#" (hash) in the URL, only for the Web. Default is setHashUrlStrategy
  /// Pay attention to the base tag in `web/index.html` when deploying locally and remotely，https://github.com/flutter/flutter/issues/69760
  setPathUrlStrategy();

  /// sp初始化
  await SpUtil.getInstance();

  /// 1.22 Preview function: Provide smooth scrolling effect when the input frequency does not match the display refresh rate
  // GestureBinding.instance?.resamplingEnabled = true;
  /// exception handling
  handleError(() => runApp(MyApp()));

  /// Hide the status bar. Set for startup page, guide page. After completion, modify it back to display the status bar.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);
  // TODO(weilu): Poor startup experience. The status bar and navigation bar are black at the beginning of the cold start, and cannot be processed by hiding or modifying the color。。。
  // Related issue tracking：https://github.com/flutter/flutter/issues/73351
}

class MyApp extends StatelessWidget {
  MyApp({super.key, this.home, this.theme}) {
    Log.init();
    initDio();
    Routes.initRoutes();
    initQuickActions();
  }

  final Widget? home;
  final ThemeData? theme;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  void initDio() {
    final List<Interceptor> interceptors = <Interceptor>[];

    /// Uniformly add authentication request header
    interceptors.add(AuthInterceptor());

    /// Refresh Token
    interceptors.add(TokenInterceptor());

    /// Print Log (production mode removed)
    if (!Constant.inProduction) {
      interceptors.add(LoggingInterceptor());
    }

    /// Adaptation data (according to your own data structure, you can choose to add it yourself)
    interceptors.add(AdapterInterceptor());
    configDio(
      baseUrl: 'https://api.github.com/',
      interceptors: interceptors,
    );
  }

  void initQuickActions() {
    if (Device.isMobile) {
      const QuickActions quickActions = QuickActions();
      if (Device.isIOS) {
        // Android restarts the activity every time, so it is placed in splash_page for processing.
        // Generally speaking, it is inconvenient to use, and this dynamic method has high limitations in Android. This is for practice only.
        quickActions.initialize((String shortcutType) async {
          if (shortcutType == 'demo') {
            navigatorKey.currentState?.push<dynamic>(MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const DemoPage(),
            ));
          }
        });
      }

      quickActions.setShortcutItems(<ShortcutItem>[
        const ShortcutItem(
            type: 'demo', localizedTitle: 'Demo', icon: 'flutter_dash_black'),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget app = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider())
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder:
            (_, ThemeProvider provider, LocaleProvider localeProvider, __) {
          return _buildMaterialApp(provider, localeProvider);
        },
      ),
    );

    /// Toast configuration
    return OKToast(
        backgroundColor: Colors.black54,
        textPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        radius: 20.0,
        position: ToastPosition.bottom,
        child: app);
  }

  Widget _buildMaterialApp(
      ThemeProvider provider, LocaleProvider localeProvider) {
    return MaterialApp(
      title: 'Flutter Deer',
      // showPerformanceOverlay: true, // show performance tab
      // debugShowCheckedModeBanner: false, // Remove the debug label in the upper right corner
      // checkerboardRasterCacheImages: true,
      // showSemanticsDebugger: true, // show semantic view
      // checkerboardOffscreenLayers: true, // Check off-screen rendering

      theme: theme ?? provider.getTheme(),
      darkTheme: provider.getTheme(isDarkMode: true),
      themeMode: provider.getThemeMode(),
      home: home ?? const SplashPage(),
      onGenerateRoute: Routes.router.generator,
      localizationsDelegates: DeerLocalizations.localizationsDelegates,
      supportedLocales: DeerLocalizations.supportedLocales,
      locale: localeProvider.locale,
      navigatorKey: navigatorKey,
      builder: (BuildContext context, Widget? child) {
        /// for android only
        if (Device.isAndroid) {
          /// Switching the dark mode will trigger this method, set the color of the navigation bar here
          ThemeUtils.setSystemNavigationBar(provider.getThemeMode());
        }

        /// Ensure that the text size is not affected by the phone system settings https://www.kikt.top/posts/flutter/layout/dynamic-text/
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },

      /// Because fluro is used, this setting is mainly for the Web
      onUnknownRoute: (_) {
        return MaterialPageRoute<void>(
          builder: (BuildContext context) => const NotFoundPage(),
        );
      },
      restorationScopeId: 'app',
    );
  }
}
