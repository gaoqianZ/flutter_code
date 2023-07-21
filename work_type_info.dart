import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermodule/common/dao/work_service.dart';
import 'package:fluttermodule/common/localization/default_localizations.dart';
import 'package:fluttermodule/model/student_user_info_entity.dart';
import 'package:fluttermodule/model/student_work_info.dart';
import 'package:fluttermodule/page/work/work_type_user_info.dart';
import 'package:fluttermodule/page/work/work_type_work_info.dart';
import 'package:fluttermodule/style/st_style.dart';
import 'package:hyflutterlib/net/data_result.dart';
import 'package:hyflutterlib/widget/hy_img_button.dart';
import 'package:hyflutterlib/widget/hy_text_button.dart';
import 'package:hyflutterlib/widget/hy_webview_page.dart';
import 'package:hyflutterlib/widget/loading/hy_loading_status_mixin.dart';
import 'package:hyflutterlib/widget/loading/hy_loading_view.dart';

// Created by GaoQian
// Date: 2021-11-16
// Description：工种信息
class WorkTypeInfoPage extends StatefulWidget {
  static const String sName = "work_type_info";

  WorkTypeInfoPage();

  @override
  WorkTypeInfoPageState createState() => WorkTypeInfoPageState();
}

class WorkTypeInfoPageState extends State<WorkTypeInfoPage>
    with
        SingleTickerProviderStateMixin,
        HYPageStateMixin,
        WidgetsBindingObserver {
  late StudentUserInfoEntity studentInfo;

  TabController? mTabController;
  int mCurrentPosition = 0;
  List tabs = ["个人信息", "工种信息"];

  late Work_list workBean;
  late int current;
  late int progress;
  late int snowId;
  late int typeId;

  Future<DataResult>? _futureBuilderFuture;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      mTabController = TabController(
          vsync: this, length: tabs.length, initialIndex: current);
    });
  }

  @override
  Widget build(BuildContext context) {
    var arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    snowId = arguments["snow_id"];
    progress = arguments["progress"];
    workBean = arguments["work"];
    current = arguments["current"];

    typeId = workBean.typeId;
    if (_futureBuilderFuture == null) {
      _futureBuilderFuture = request();
    }

    return Scaffold(
      backgroundColor: STColors.bg,
      appBar: getHYMiniProgramAppBar(
          title: HYLocalizations.i18n(context)!.work_type_info,
          backgroundColor: STColors.white),
      body: _renderFutureBuilder(),
    );
  }

  ///数据请求
  Future<DataResult> request() async {
    DataResult res = await WorkService.getStudentInfo(typeId, snowId);
    return res;
  }

  //获取班级
  Future getStudentInfo() async {
    DataResult result = await request();
    if (result.result) {
      setState(() {
        studentInfo = result.data;
        loadingViewKey?.currentState?.updateStatus(LoadingStatus.loading_suc);
        _renderDataView();
      });
    } else {
      loadingViewKey?.currentState?.updateStatus(LoadingStatus.error);
    }
  }

  _renderEmptyView() {
    loadingStatus = LoadingStatus.loading_suc_but_empty;
    return _renderLoadingView();
  }

  _renderDataView() {
    if (studentInfo == null) {
      _renderEmptyView();
    }
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              floating: true,
              backgroundColor: STColors.white,
              elevation: 5,
              shadowColor: Color.fromARGB(50, 0, 0, 0),
              expandedHeight: 200,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.only(
                              top: STDimen.dp_20,
                              bottom: STDimen.dp_20,
                              left: STDimen.dp_15,
                              right: STDimen.dp_15),
                          color: Colors.white,
                          child: Column(
                            children: [
                              _infoTop(),
                              Padding(
                                  padding: EdgeInsets.only(top: STDimen.dp_15)),
                              _infoBottom(),
                            ],
                          )),
                      Container(
                        color: STColors.bg,
                        height: STDimen.dp_10,
                      ),
                    ],
                  )),
              bottom: WorkTypeTabBar(
                  tabBar: TabBar(
                      controller: mTabController,
                      indicatorColor: STColors.theme,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: STDimen.dp_2,
                      indicatorPadding: EdgeInsets.only(
                          left: STDimen.dp_20, right: STDimen.dp_20),
                      labelColor: STColors.black222,
                      labelStyle: TextStyle(
                          fontSize: STFonts.textSize_15,
                          fontWeight: FontWeight.bold),
                      unselectedLabelColor: STColors.black222,
                      unselectedLabelStyle: TextStyle(
                          fontSize: STFonts.textSize_15,
                          fontWeight: FontWeight.w400),
                      tabs: tabs.map((value) => Tab(text: value)).toList())),
            )
          ];
        },
        body: TabBarView(controller: mTabController, children: [
          WorkTypeUserInfoPage(studentInfo),
          WorkTypeWorkInfoPage(snowId: snowId, typeId: typeId)
        ]));
  }

  Row _infoTop() {
    return Row(
      children: [
        Expanded(
            child: Row(
          children: [
            ClipOval(
              child: Image.network(
                studentInfo.avatar,
                width: STDimen.dp_60,
                height: STDimen.dp_60,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  return Image.asset(
                    "static/images/icon_default_head.png",
                    width: STDimen.dp_60,
                    height: STDimen.dp_60,
                  );
                },
              ),
            ),
            Padding(padding: EdgeInsets.only(left: STDimen.dp_12)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentInfo.realName,
                  style: STFonts.text16_222_Bold,
                ),
                SizedBox(height: 6.0),
                Text(
                  studentInfo.hidePhone,
                  style: STFonts.text12_666,
                ),
              ],
            ),
          ],
        )),
        GestureDetector(
          child: Row(
            children: [
              Text(
                "简历$progress%",
                style: STFonts.text14_theme,
              ),
              Padding(padding: EdgeInsets.only(left: STDimen.dp_8)),
              Image.asset(
                "static/images/icon_arrow_right.png",
                width: STDimen.dp_8,
                height: STDimen.dp_14,
              )
            ],
          ),
          onTap: () {
            Navigator.of(context)
                .push(new CupertinoPageRoute(builder: (context) {
              return HYWebViewPage(
                url: studentInfo.resumeLink,
                appbarIsTheme: false,
              );
            }));
          },
        )
      ],
    );
  }

  _renderLoadingView() {
    return setUpLoadingView(
        child: Container(),
        todoAfterError: (loadingView) {
          loadingViewKey?.currentState?.updateStatus(LoadingStatus.loading);
          getStudentInfo();
        },
        todoAfterNetworkBlocked: (loadingView) {
          loadingViewKey?.currentState?.updateStatus(LoadingStatus.loading);
          getStudentInfo();
        });
  }

  _renderFutureBuilder() {
    return FutureBuilder<DataResult>(
        future: _futureBuilderFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              {
                return _renderLoadingView();
              }
            case ConnectionState.done:
              {
                if (snapshot.data != null) {
                  DataResult result = snapshot.data as DataResult;
                  if (result.result) {
                    studentInfo = result.data;
                    loadingViewKey?.currentState
                        ?.updateStatus(LoadingStatus.loading_suc);
                    return _renderDataView();
                  } else {
                    loadingStatus = LoadingStatus.error;
                    return _renderLoadingView();
                  }
                } else {
                  loadingStatus = LoadingStatus.error;
                  return _renderLoadingView();
                }
              }
            default:
              {
                loadingStatus = LoadingStatus.error;
                return _renderLoadingView();
              }
          }
        });
  }

  _infoBottom() {
    return SizedBox(
        height: 24.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(workBean.name, style: STFonts.text14_222),
            SizedBox(width: STDimen.dp_8),
            SizedBox(
                width: STDimen.dp_38,
                height: STDimen.dp_16,
                child: HYTextButton(
                    title: workBean.auth, fontsize: 10.0, cornerRadius: 3.0)),
            Expanded(child: Container()),
            sizedBoxLabel(studentInfo.baseInfo, "个人信息"),
            SizedBox(width: STDimen.dp_12),
            sizedBoxLabel(studentInfo.workInfo, "工种信息"),
          ],
        ));
  }

  SizedBox sizedBoxLabel(bool status, String title) {
    return SizedBox(
        width: STDimen.dp_62,
        height: STDimen.dp_16,
        child: HYImageTextButton(
          image: Image.asset(
            status ? STICons.iconWorkRight : STICons.iconWorkWrong,
            width: STDimen.dp_10,
            height: STDimen.dp_10,
          ),
          textColor: STColors.black666,
          text: title,
          fontSize: STFonts.textSize_10,
          cornerRadius: STDimen.dp_3,
          imageTextSpace: 4,
          borderWidth: STDimen.dp_0_5,
          borderColor: STColors.black999,
          opposite: false,
        ));
  }
}

class WorkTypeTabBar extends StatelessWidget implements PreferredSizeWidget {
  const WorkTypeTabBar({Key? key, required this.tabBar}) : super(key: key);

  final TabBar tabBar;

  @override
  Size get preferredSize {
    double toolHeight = 0.5;
    Size size = Size.fromHeight(tabBar.preferredSize.height + toolHeight);
    return size;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [tabBar, Divider(height: 0.5, color: STColors.division)],
    );
  }
}
