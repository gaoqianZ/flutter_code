import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermodule/model/student_user_info_entity.dart';
import 'package:fluttermodule/style/st_style.dart';
import 'package:hyflutterlib/widget/loading/hy_loading_status_mixin.dart';

// Created by GaoQian
// Date: 2021-11-16
// Description：工种个人信息
class WorkTypeUserInfoPage extends StatefulWidget {
  final StudentUserInfoEntity _studentInfo;

  WorkTypeUserInfoPage(this._studentInfo, {Key? key}) : super(key: key);

  static const String sName = "work_type_user_info";

  @override
  WorkTypeUserInfoPageState createState() => WorkTypeUserInfoPageState();
}

class WorkTypeUserInfoPageState extends State<WorkTypeUserInfoPage>
    with HYPageStateMixin {
  @override
  Widget build(BuildContext context) {
    List<StudentUserInfoList>? list = widget._studentInfo.xList;

    return Container(
      child: ListView.separated(
          itemBuilder: (context, index) {
            StudentUserInfoList studentUserInfo = list[index];
            return Container(
                padding: EdgeInsets.only(
                    left: STDimen.dp_15,
                    right: STDimen.dp_15,
                    top: STDimen.dp_12,
                    bottom: STDimen.dp_12),
                color: STColors.white,
                child: _judgeValue(studentUserInfo));
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: STDimen.dp_0_5,
              color: STColors.division,
              endIndent: STDimen.dp_15,
              indent: STDimen.dp_15,
            );
          },
          itemCount: list.length),
    );
  }

  _judgeValue(StudentUserInfoList studentUserInfo) {
    try {
      if (studentUserInfo.value != null) {
        if (studentUserInfo.displayUnit != null &&
            studentUserInfo.displayUnit!.isNotEmpty) {
          return _rowLayout(
              studentUserInfo.key,
              studentUserInfo.value.toString() +
                  studentUserInfo.displayUnit.toString());
        }
        return _rowLayout(
            studentUserInfo.key, studentUserInfo.value.toString());
      } else if (studentUserInfo.options != null &&
          studentUserInfo.options!.isNotEmpty) {
        StringBuffer stringBuffer = new StringBuffer();
        studentUserInfo.options!.forEach((element) {
          if (element.isCheck) {
            stringBuffer
              ..write(element.value)
              ..write("、");
          }
        });
        if (stringBuffer.isEmpty) {
          return _rowLayout(studentUserInfo.key, "未完善");
        }
        return _rowLayout(
            studentUserInfo.key,
            stringBuffer.length > 1
                ? stringBuffer.toString().replaceRange(
                    stringBuffer.length - 1, stringBuffer.length, "")
                : stringBuffer.toString());
      } else if (studentUserInfo.experienceList != null &&
          studentUserInfo.experienceList!.isNotEmpty) {
        List<StudentUserInfoListExperienceList>? experienceList =
            studentUserInfo.experienceList;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studentUserInfo.key,
              style: STFonts.text14_666,
            ),
            Padding(padding: EdgeInsets.only(bottom: STDimen.dp_8)),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: experienceList!.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(
                      left: STDimen.dp_12,
                      right: STDimen.dp_12,
                      top: STDimen.dp_15,
                      bottom: STDimen.dp_15),
                  decoration: BoxDecoration(
                      color: STColors.bg,
                      borderRadius: BorderRadius.circular(STDimen.dp_10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            experienceList[index].type,
                            style: STFonts.text14_222,
                          )),
                          Text(
                            experienceList[index].startTime +
                                "—" +
                                experienceList[index].endTime,
                            style: STFonts.text14_222,
                          )
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: STDimen.dp_8)),
                      Text(experienceList[index].workContent,
                          style: STFonts.text12_666)
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: STDimen.dp_10,
                );
              },
            )
          ],
        );
      } else {
        return _rowLayout(studentUserInfo.key, "未完善");
      }
    } catch (e) {
      print(e);
    }
  }

  Row _rowLayout(String key, String value) {
    if(value.isEmpty){
      value="未完善";
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Text(
          key,
          style: STFonts.text14_666,
        )),
        Expanded(
            flex: 2,
            child: Text(
              value,
              style: value == "未完善"
                  ? STFonts.text14_warn
                  : STFonts.text14_222,
              textAlign: TextAlign.end,
            ))
      ],
    );
  }
}
