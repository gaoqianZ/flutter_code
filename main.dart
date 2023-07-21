import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:fluttermodule/page/addendance/attendance_statistics_page.dart';
import 'package:fluttermodule/page/exam/choose_student_page.dart';
import 'package:fluttermodule/page/exam/choose_test_page.dart';
import 'package:fluttermodule/page/exam/class_detail_page.dart';
import 'package:fluttermodule/page/exam/graduation_score_page.dart';
import 'package:fluttermodule/page/exam/publish_exam_page.dart';
import 'package:fluttermodule/page/exam/reissue_test_paper_page.dart';
import 'package:fluttermodule/page/teacher_home_page.dart';
import 'package:fluttermodule/page/work/work_type_info.dart';
import 'package:hyflutterlib/config/config.dart';
import 'package:hyflutterlib/style/hy_style.dart';
import 'package:hyflutterlib/model/User.dart';
import 'package:hyflutterlib/redux/hy_state.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyflutterlib/utils/common_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:hyflutterlib/event/http_error_event.dart';
import 'package:hyflutterlib/event/index.dart';
import 'common/localization/default_localizations.dart';
import 'package:hyflutterlib/net/code.dart';
import 'package:fluttermodule/common/localization/hy_localizations_delegate.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() {
  CustomFlutterBinding();
  configLoading();
  PageVisibilityBinding.instance.addGlobalObserver(AppLifecycleObserver());
  runApp(FlutterReduxApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
  //..customAnimation = CustomAnimation();
}

class FlutterReduxApp extends StatefulWidget {
  _FlutterReduxAppState createState() => _FlutterReduxAppState();
}

class CustomFlutterBinding extends WidgetsFlutterBinding
    with BoostFlutterBinding {}

class _FlutterReduxAppState extends State<FlutterReduxApp>
    with HttpErrorListener, NavigatorObserver {
  /// 创建Store，引用 GSYState 中的 appReducer 实现 Reducer 方法
  /// initialState 初始化 State
  final store = new Store<HYState>(
    appReducer,

    ///拦截器
    middleware: middleware,

    ///初始化数据
    initialState: new HYState(
        userInfo: User.empty(),
        login: false,
        themeData: CommonUtils.getThemeData(HYColors.primarySwatch),
        locale: Locale('zh', 'CH')),
  );

  ///路由表
  final Map<String, FlutterBoostRouteFactory> routerMap = {
    TeacherHomePage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings,
          builder: (_) {
            Map<String, String> map = new Map<String, String>.from(
                settings.arguments as Map<String, dynamic>);
            return TeacherHomePage(map);
          });
    },
    ClassDetailPage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => ClassDetailPage());
    },
    AttendanceStatisticPage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => AttendanceStatisticPage());
    },
    ChooseTestPage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => ChooseTestPage());
    },
    ChooseStudentPage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => ChooseStudentPage());
    },
    ReissueTestPaperPage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => ReissueTestPaperPage());
    },
    GraduationScorePage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => GraduationScorePage());
    },
    WorkTypeInfoPage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => WorkTypeInfoPage());
    },
    PublishExamPage.sName: (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => PublishExamPage());
    },
  };

  Route<dynamic>? routeFactory(RouteSettings settings, String? uniqueId) {
    FlutterBoostRouteFactory? func = routerMap[settings.name];
    if (func == null) {
      return null;
    }
    return func(settings, uniqueId);
  }

  @override
  void initState() {
    super.initState();
    Config.init(
        appid: "313",
        appsecret: "2a0781af28c89106",
        themecolor: HYColors.theme);
    //Config.updateUserInfo(utoken: "149359dab8983db01a71df9279253b99");
    // Config.baseUrl = "https://pre-apis.mumway.com";
    // Global.init();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(routeFactory, appBuilder: appBuilder);
  }

  Widget appBuilder(Widget home) {
    return new StoreProvider(
      store: store,
      child: new StoreBuilder<HYState>(builder: (context, store) {
        ///使用 StoreBuilder 获取 store 中的 theme 、locale
        store.state.platformLocale = WidgetsBinding.instance!.window.locale;

        return RefreshConfiguration(
            headerBuilder: () => WaterDropHeader(),
            // 配置默认头部指示器,假如你每个页面的头部指示器都一样的话,你需要设置这个
            footerBuilder: () => ClassicFooter(),
            // 配置默认底部指示器
            headerTriggerDistance: 80.0,
            // 头部触发刷新的越界距离
            springDescription:
                SpringDescription(stiffness: 170, damping: 16, mass: 1.9),
            // 自定义回弹动画,三个属性值意义请查询flutter api
            maxOverScrollExtent: 100,
            //头部最大可以拖动的范围,如果发生冲出视图范围区域,请设置这个属性
            maxUnderScrollExtent: 30,
            // 底部最大可以拖动的范围
            enableScrollWhenRefreshCompleted: true,
            //这个属性不兼容PageView和TabBarView,如果你特别需要TabBarView左右滑动,你需要把它设置为true
            enableLoadingWhenFailed: true,
            //在加载失败的状态下,用户仍然可以通过手势上拉来触发加载更多
            hideFooterWhenNotFull: false,
            // Viewport不满一屏时,禁用上拉加载更多功能
            enableBallisticLoad: true,
            // 可以通过惯性滑动触发加载更多
            child: MaterialApp(
                title: 'Welcome to Flutter',
                debugShowCheckedModeBanner: false,
                // showPerformanceOverlay: true,
                // checkerboardOffscreenLayers: true,
                localizationsDelegates: [
                  ///初始化默认的 Material 组件本地化
                  GlobalMaterialLocalizations.delegate,
                  RefreshLocalizations.delegate,
                  PickerLocalizationsDelegate
                      .delegate, // 如果要使用本地化，请添加此行，则可以显示中文按钮
                  GlobalCupertinoLocalizations.delegate,

                  ///初始化默认的 通用 Widget 组件本地化
                  GlobalWidgetsLocalizations.delegate,
                  HYLocalizationsDelegate.delegate,
                ],

                ///当前区域，如果为null则使用系统区域一般用于语言切换
                ///传入两个参数，语言代码，国家代码
                ///这里配制为中国
                locale: Locale('zh', 'CN'),

                ///传入支持的语种数组
                supportedLocales: [
                  const Locale('en', 'US'), // English 英文
                  const Locale('he', 'IL'), // Hebrew 西班牙
                  const Locale('zh', 'CN'), // 中文，后面的countryCode暂时不指定
                ],
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case ClassDetailPage.sName:
                      return CupertinoPageRoute(
                          builder: (_) => ClassDetailPage(),
                          settings: settings);
                    case AttendanceStatisticPage.sName:
                      return CupertinoPageRoute(
                          builder: (_) => AttendanceStatisticPage(),
                          settings: settings);
                    case PublishExamPage.sName:
                      return CupertinoPageRoute(
                          builder: (_) => PublishExamPage(),
                          settings: settings);
                    case ChooseTestPage.sName:
                      return CupertinoPageRoute(
                          builder: (_) => ChooseTestPage(), settings: settings);
                    case ChooseStudentPage.sName:
                      return CupertinoPageRoute(
                          builder: (_) => ChooseStudentPage(),
                          settings: settings);
                    case ReissueTestPaperPage.sName:
                      return CupertinoPageRoute(
                          builder: (_) => ReissueTestPaperPage(),
                          settings: settings);
                    case GraduationScorePage.sName:
                      return CupertinoPageRoute(
                          builder: (_) => GraduationScorePage(),
                          settings: settings);
                    case WorkTypeInfoPage.sName:
                      return CupertinoPageRoute(
                          builder: (_) => WorkTypeInfoPage(),
                          settings: settings);
                  }
                },
                builder: (context, widget) {
                  EasyLoading.init();
                  return MediaQuery(
                      data:
                          MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: widget ?? home);
                },
                // routes: {
                //   AttendanceStatisticPage.sName: (context) =>
                //       AttendanceStatisticPage(),
                //   PublishExamPage.sName: (context) => PublishExamPage(),
                //   ChooseTestPage.sName: (context) => ChooseTestPage(),
                //   ChooseStudentPage.sName: (context) => ChooseStudentPage(),
                // },
                // home: TeacherHomePage(
                // {"least_version": "1", "appid": "10001"}))); //VSCODE 启动模式
                home: home));
      }),
    );
    //return MaterialApp(home: home, debugShowCheckedModeBanner: false);
  }
}

// Map<String, String> _parseSchemeUrl(String url) {
//   Uri u = Uri.parse(url);
//   return u.queryParameters;
// }
///全局生命周期监听示例
class AppLifecycleObserver with GlobalPageVisibilityObserver {
  @override
  void onBackground(Route route) {
    super.onBackground(route);
    print("AppLifecycleObserver - onBackground");
  }

  @override
  void onForeground(Route route) {
    super.onForeground(route);
    print("AppLifecycleObserver - onForground");
  }

  @override
  void onPagePush(Route route) {
    super.onPagePush(route);
    print("AppLifecycleObserver - onPagePush");
  }

  @override
  void onPagePop(Route route) {
    super.onPagePop(route);
    print("AppLifecycleObserver - onPagePop");
  }

  @override
  void onPageHide(Route route) {
    super.onPageHide(route);
    print("AppLifecycleObserver - onPageHide");
  }

  @override
  void onPageShow(Route route) {
    super.onPageShow(route);
    print("AppLifecycleObserver - onPageShow");
  }
}

mixin HttpErrorListener on State<FlutterReduxApp> {
  StreamSubscription? stream;

  ///这里为什么用 _context 你理解吗？
  ///因为此时 State 的 context 是 FlutterReduxApp 而不是 MaterialApp
  ///所以如果直接用 context 是会获取不到 MaterialApp 的 Localizations 哦。
  late BuildContext _context;

  @override
  void initState() {
    super.initState();

    ///Stream演示event bus
    stream = eventBus.on<HttpErrorEvent>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (stream != null) {
      stream!.cancel();
      stream = null;
    }
  }

  ///网络错误提醒
  errorHandleFunction(int? code, message) {
    switch (code) {
      case Code.NETWORK_ERROR:
        showToast(HYLocalizations.i18n(_context)!.network_error);
        break;
      case 401:
        showToast(HYLocalizations.i18n(_context)!.network_error_401);
        break;
      case 403:
        showToast(HYLocalizations.i18n(_context)!.network_error_403);
        break;
      case 404:
        showToast(HYLocalizations.i18n(_context)!.network_error_404);
        break;
      case 422:
        showToast(HYLocalizations.i18n(_context)!.network_error_422);
        break;
      case Code.NETWORK_TIMEOUT:
        //超时
        showToast(HYLocalizations.i18n(_context)!.network_error_timeout);
        break;
      // case Code.GITHUB_API_REFUSED:
      //   //Github API 异常
      //   showToast(HYLocalizations.i18n(_context)!.github_refused);
      //   break;
      default:
        showToast(HYLocalizations.i18n(_context)!.network_error_unknown +
            " " +
            message);
        break;
    }
  }

  showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG);
  }
}
