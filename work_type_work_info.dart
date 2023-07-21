import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermodule/common/dao/work_service.dart';
import 'package:fluttermodule/model/work_info.dart';
import 'package:fluttermodule/style/st_style.dart';
import 'package:hyflutterlib/net/data_result.dart';
import 'package:hyflutterlib/widget/loading/hy_loading_status_mixin.dart';
import 'package:hyflutterlib/widget/loading/hy_loading_view.dart';

// Created by GaoQian
// Date: 2021-11-17
// Description：工作信息
class WorkTypeWorkInfoPage extends StatefulWidget {
  const WorkTypeWorkInfoPage(
      {Key? key, required this.typeId, required this.snowId})
      : super(key: key);
  final int typeId;
  final int snowId;

  @override
  WorkTypeWorkInfoState createState() => WorkTypeWorkInfoState();
}

class WorkTypeWorkInfoState extends State<WorkTypeWorkInfoPage>
    with AutomaticKeepAliveClientMixin, HYPageStateMixin {
  WorkInfo? _model;

  @override
  bool get wantKeepAlive => true;

  late Future<DataResult> _futureBuilderFuture;

  @override
  void initState() {
    super.initState();

    _futureBuilderFuture = _request();
  }

  ///数据请求
  Future<DataResult> _request() async {
    DataResult res = await WorkService.getWorkInfo(
        typeId: widget.typeId, snowId: widget.snowId);
    return res;
  }

  Future _reload() async {
    DataResult result = await _request();
    if (result.result) {
      setState(() {
        _model = result.data as WorkInfo;
        if (_model != null) {
          if (_model!.list.isEmpty) {
            loadingViewKey?.currentState
                ?.updateStatus(LoadingStatus.loading_suc_but_empty);
            _renderEmptyView();
          } else {
            loadingViewKey?.currentState
                ?.updateStatus(LoadingStatus.loading_suc);
            _renderDataView();
          }
        } else {
          loadingViewKey?.currentState
              ?.updateStatus(LoadingStatus.loading_suc_but_empty);
          _renderEmptyView();
        }
      });
    } else {
      loadingViewKey?.currentState?.updateStatus(LoadingStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _renderFutureBuilder();
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
                    _model = result.data as WorkInfo;
                    if (_model != null) {
                      if (_model!.list.isEmpty) {
                        loadingViewKey?.currentState
                            ?.updateStatus(LoadingStatus.loading_suc_but_empty);
                        return _renderEmptyView();
                      } else {
                        loadingViewKey?.currentState
                            ?.updateStatus(LoadingStatus.loading_suc);
                        return _renderDataView();
                      }
                    }
                    return _renderEmptyView();
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

  _renderLoadingView() {
    return setUpLoadingView(
        child: Container(),
        todoAfterNetworkBlocked: (HYLoadingView widget) {
          // 网络错误，点击重试
          loadingViewKey?.currentState?.updateStatus(LoadingStatus.loading);
          _reload();
        },
        todoAfterError: (HYLoadingView widget) {
          // 接口错误，点击重试
          loadingViewKey?.currentState?.updateStatus(LoadingStatus.loading);
          _reload();
        },
        todoAfterNoDataBlocked: (HYLoadingView widget) {
          // 暂无数据，点击重试
          loadingViewKey?.currentState?.updateStatus(LoadingStatus.loading);
          _reload();
        });
  }

  _renderEmptyView() {
    loadingStatus = LoadingStatus.loading_suc_but_empty;
    return _renderLoadingView();
  }

  _renderDataView() {
    List<String> leftArr = _model!.list.map((e) => e.display).toList();
    List<String> rightArr = _model!.list.map((e) {
      return (e.value + e.displayUnit);
    }).toList();
    return ListView.separated(
        itemBuilder: (context, index) {
          String leftTitle = leftArr[index];
          String rightTitle = rightArr[index];
          return Container(
              padding: EdgeInsets.fromLTRB(15.0, 12.0, 15.0, 12.0),
              color: STColors.white,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 115.0,
                        child: Text(leftTitle,
                            style: STFonts.text14_666,
                            textAlign: TextAlign.left)),
                    SizedBox(width: 20.0),
                    Expanded(
                        child: Text(rightTitle.isNotEmpty ? rightTitle : "未完善",
                            style: rightTitle.isEmpty
                                ? STFonts.text14_warn
                                : STFonts.text14_222,
                            textAlign: TextAlign.right)),
                  ]));
        },
        separatorBuilder: (context, index) {
          return Divider(
              height: 0.5,
              color: STColors.division,
              indent: 15.0,
              endIndent: 15.0);
        },
        itemCount: leftArr.length);
  }
}
