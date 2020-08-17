import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rich_edit/rich_edit_label.dart';
import 'package:rich_edit/rich_edit_theme.dart';

export 'rich_edit_label.dart';
export 'rich_edit_theme.dart';
export 'rich_edit_toolbar.dart';

enum RichEditDataType { TEXT, IMAGE, VIDEO, NONE }

class RichEditData {
  // 数据
  dynamic data;

  // 数据类型
  RichEditDataType type;

  // Text控制器，仅在type为TEXT为有效
  TextEditingController controller;

  // TextFocus，仅在type为TEXT为有效
  FocusNode controllerFocus;

  // 主题
  RichEditTheme theme;

  // 只读
  bool onOly;

  RichEditData(
    RichEditDataType type,
    dynamic data, {
    TextEditingController controller,
    FocusNode controllerFocus,
    RichEditTheme theme,
    bool onOly = false,
  })  : type = type ?? RichEditDataType.TEXT,
        data = data ?? "",
        theme = theme ?? RichEditTheme(),
        controller = controller ?? TextEditingController(),
        controllerFocus = controllerFocus ?? FocusNode();
}

abstract class RichEditController {
  final List<RichEditData> _data = List.of({
    RichEditData(
      RichEditDataType.TEXT,
      "",
    )
  });

  final TextStyle textStyle;

  final InputDecoration inputDecoration;

  final Icon deleteIcon;

  Function addView;

  Function initial;

  RichEditController({
    this.textStyle,
    InputDecoration inputDecoration,
    Icon deleteIcon,
    Icon imageIcon,
    Icon videoIcon,
  })  : deleteIcon = deleteIcon ?? Icon(Icons.cancel),
        inputDecoration = inputDecoration ??
            InputDecoration(
              hintText: "点击可输入内容..",
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            );

  addImage();

  addVideo();

  generateImageView(RichEditData data);

  generateVideoView(RichEditData data);

  String generateHtml() {
    StringBuffer sb = StringBuffer();
    _data.forEach((element) {
      switch (element.type) {
        case RichEditDataType.TEXT:
          generateTextHtml(sb, element);
          break;
        case RichEditDataType.IMAGE:
          generateImageHtml(sb, element);
          break;
        case RichEditDataType.VIDEO:
          generateVideoHtml(sb, element);
          break;
      }
    });
    return sb.toString();
  }

  String remStringHtml(text) {
    RegExp reg = new RegExp("<[^>]*>");
    Iterable<RegExpMatch> matches = reg.allMatches(text);
    String value = "";

    matches.forEach((m) {
      value = m.input.toString().replaceAll(reg, "");
    });

    return value;
  }

  List generateView(String html) {
    RegExp regDom = new RegExp('<[img|images|p|br].*?>([^\<]*?)<\/[img|images|p|br]>|<img.*?src="(.*?)".*?\/?>');
    RegExp regDomImgSrc = new RegExp(" src=\"(.*)\" ");

    Iterable<RegExpMatch> matches = regDom.allMatches(html);

    if (html == "") {
      return [];
    }

    _data.removeAt(0);

    matches.forEach((m) {
      String DomContent = m.input.substring(m.start, m.end);
      Iterable<RegExpMatch> srcValue = regDomImgSrc.allMatches(DomContent);

      /// img or image tag
      srcValue.forEach((_rt) {
        String src = _rt.input.substring(_rt.start, _rt.end).replaceAll("src=\"", "").replaceAll("\"", "");
        if (DomContent.toString().indexOf("<img") >= 0) {
          _data.addAll([
            RichEditData(
              RichEditDataType.IMAGE,
              src.trim(),
            ),
//            _data.length > 0 &&
//                    (_data[_data.length - 1].type == RichEditDataType.IMAGE || _data[_data.length - 1].type == RichEditDataType.VIDEO)
//                ? RichEditData(
//                    RichEditDataType.TEXT,
//                    "",
//                    controller: TextEditingController(),
//                    controllerFocus: FocusNode(),
//                  )
//                : RichEditData(
//                    RichEditDataType.NONE,
//                    "",
//                  ),
          ]);
        }
      });

      if (DomContent.toString().indexOf("<p") >= 0) {
        _data.add(
          RichEditData(
            RichEditDataType.TEXT,
            this.remStringHtml(m.input.substring(m.start, m.end)),
            controller: TextEditingController(),
            controllerFocus: FocusNode(),
          ),
        );
      }
    });

    _data.add(
      RichEditData(
        RichEditDataType.TEXT,
        "",
        controller: TextEditingController(),
        controllerFocus: FocusNode(),
      ),
    );
  }

  void generateTextHtml(StringBuffer sb, RichEditData element) {
    if (element.data != "") {
      sb.write("<p>");
      sb.write(element.data);
      sb.write("<\/p>");
    }
  }

  void generateImageHtml(StringBuffer sb, RichEditData element) {
    if (element.data != "") {
      sb.write("<img src=\"");
      sb.write(element.data);
      sb.write("\" />");
    }
  }

  void generateVideoHtml(StringBuffer sb, RichEditData element) {
    sb.write("<p>");
    sb.write('''
          <video src="${element.data}" playsinline="true" webkit-playsinline="true" x-webkit-airplay="allow" airplay="allow" x5-video-player-type="h5" x5-video-player-fullscreen="true" x5-video-orientation="portrait" controls="controls"  style="width: 100%;height: 300px;"></video>
          ''');
    sb.write("<\/p>");
  }

  List<RichEditData> getDataList() {
    return _data;
  }
}

class RichEdit extends StatefulWidget {
  final RichEditController controller;

  RichEdit(
    this.controller, {
    Key key,
  }) : super(key: key);

  @override
  RichEditState createState() => new RichEditState();
}

class RichEditState extends State<RichEdit> {
  ScrollController _controller;
  Map<int, FocusNode> focusNodes = Map();
  Map<int, TextEditingController> textControllers = Map();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    widget.controller.addView = addView;
    widget.controller.initial = initial;
  }

  @override
  Widget build(BuildContext context) {
    focusNodes.clear();
    textControllers.clear();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView(
        children: <Widget>[
          Column(
            children: widget.controller._data.asMap().keys.map((index) {
              var data = widget.controller._data[index];
              Widget item = Container();
              switch (data.type) {
                case RichEditDataType.NONE:
                  item = Container();
                  break;
                case RichEditDataType.TEXT:
                  textControllers[index] = widget.controller._data[index].controller;
                  focusNodes[index] = widget.controller._data[index].controllerFocus;

                  /// 赋予值
                  textControllers[index].text = data.data;

                  /// 监听变动
                  textControllers[index].addListener(() {});

                  item = richEditLabel.P(
                    context,
                    index,
                    focusNodes,
                    textControllers,
                    widget.controller.textStyle,
                    onChanged: (text) {
                      print(text.toString().length);
                      if (text.toString().length <= 0 && widget.controller._data.length > 1) {
                        setState(() {
                          focusNodes.remove(focusNodes[index]);
                          widget.controller._data.removeAt(index);
                        });
                        return;
                      }

                        if (text.indexOf("\n") >= 0) {
                          List t = text.split("\n");
                          widget.controller._data[index].data = t[0];
                          widget.controller._data[index].controllerFocus.unfocus();
                          widget.controller._data.insert(
                            index + 1,
                            RichEditData(
                              RichEditDataType.TEXT,
                              t.length > 1 ? t[1].toString().replaceAll("\n", "") ?? "" : "",
                            ),
                          );

//                      focusNodes[index].nextFocus();

                          FocusScope.of(context).requestFocus(widget.controller._data[index + 1].controllerFocus);

                          setState(() {});
                        } else {
                          widget.controller._data[index].data = text;
                        }
                      },
                  );
                  break;
                case RichEditDataType.IMAGE:
                  item = richEditLabel.IMG(
                    widget.controller.generateImageView(data),
                    onChanged: () => remove(index),
                  );
                  break;
                case RichEditDataType.VIDEO:
                  item = Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              remove(index);
                            },
                          ),
                          widget.controller.generateVideoView(data),
                        ],
                      ));
              }
              return item;
            }).toList(),
          )
        ],
      )
    );
  }

  void initial() {
    setState(() {
      widget.controller._data.asMap().keys.map((index) {
        remove(index);
      });
      widget.controller._data.add(RichEditData(
        RichEditDataType.TEXT,
        "",
      ));
    });
  }

  void remove(int index) {
    var next = widget.controller._data[index + 1];
    if (next != null && next.data == "") {
      widget.controller._data.removeAt(index + 1);
      widget.controller._data.removeAt(index);
    } else if (index > 0) {
      var pre = widget.controller._data[index - 1];
      if (pre.type == RichEditDataType.TEXT) {
        pre.data += "\n${next.data}";
      }
      widget.controller._data.removeAt(index);
      widget.controller._data.removeAt(index);
    }

    setState(() {});
  }

  void addView(RichEditData richEditData) {
    int insertIndex = widget.controller._data.length;
    String text = "";
    focusNodes.forEach((key, value) {
      if (value.hasFocus) {
        insertIndex = key + 1;
        var textController = textControllers[key];
        text = textController.selection.textAfter(textController.text);
        widget.controller._data[key].data = textController.text.substring(0, textController.text.length - text.length);
      }
    });
    widget.controller._data.insert(insertIndex, richEditData);
    widget.controller._data.insert(insertIndex + 1, RichEditData(RichEditDataType.TEXT, text));
    setState(() {});
  }
}
