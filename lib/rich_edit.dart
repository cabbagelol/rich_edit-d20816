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

  bool autofocus;

  RichEditData(
    RichEditDataType type, {
    dynamic data,
    TextEditingController controller,
    FocusNode controllerFocus,
    RichEditTheme theme,
    bool onOly = false,
    this.autofocus = false,
  })  : type = type ?? RichEditDataType.TEXT,
        data = data ?? "",
        theme = theme ?? RichEditTheme(),
        controller = controller ?? TextEditingController(),
        controllerFocus = controllerFocus ?? FocusNode();
}

abstract class RichEditController {
  List<RichEditData> _data = List.of({
    RichEditData(
      RichEditDataType.TEXT,
    )
  });

  final TextStyle textStyle;
  Function addView;
  Function initial;

  RichEditController({
    this.textStyle,
  });

  addImage();

  addVideo();

  Widget generateImageView(RichEditData data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      color: Colors.black12,
      child: Center(
        child: Text("图片地址"),
      ),
    );
  }

  Widget generateVideoView(RichEditData data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      color: Colors.black12,
      child: Center(
        child: Text("视频地址"),
      ),
    );
  }

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
        default:
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
          _data.add(RichEditData(
            RichEditDataType.IMAGE,
            data: src.trim(),
          ));
        }
      });

      if (DomContent.toString().indexOf("<p") >= 0) {
        _data.add(
          RichEditData(
            RichEditDataType.TEXT,
            data: this.remStringHtml(
              m.input.substring(m.start, m.end),
            ),
          ),
        );
      }
    });
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
  Map<int, Map> animateds = new Map();
  Map<int, FocusNode> focusNodes = Map();
  Map<int, TextEditingController> textControllers = Map();

  @override
  void initState() {
    super.initState();
    widget.controller.addView = addView;
    widget.controller.initial = initial;
  }

  @override
  Widget build(BuildContext context) {
//    focusNodes.clear();
//    textControllers.clear();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.controller._data.asMap().keys.map((index) {
              RichEditData data = widget.controller._data[index];

              switch (data.type) {
                case RichEditDataType.NONE:
                  return Container();
                  break;
                case RichEditDataType.TEXT:
                  textControllers[index] = widget.controller._data[index].controller;
                  focusNodes[index] = widget.controller._data[index].controllerFocus;

                  // 赋予值
                  textControllers[index].text = data.data;

                  textControllers[index] = TextEditingController(
                    text: data.data,
                  );

                  return richEditLabel.P(
                    context,
                    data,
                    focusNodes[index],
                    textControllers[index],
                    widget.controller.textStyle,
                    onChanged: (text) {
                      if (text == "" && widget.controller._data.length > 1) {
                        setState(() {
                          focusNodes.remove(focusNodes[index]);
                          widget.controller._data.removeAt(index);
                        });
                        return;
                      }

                      widget.controller._data[index].data = text;
                    },
                  );
                  break;
                case RichEditDataType.IMAGE:
                  animateds[index] = {
                    "padValue": 30.0,
                  };

                  return richEditLabel.IMG(
                    widget.controller.generateImageView(data),
                    onChanged: () => remove(index),
                  );
                  break;
                case RichEditDataType.VIDEO:
                  return richEditLabel.VIDEO(
                    widget.controller.generateVideoView(data),
                    onChanged: () => remove(index),
                  );
              }
            }).toList(),
          ),
          SizedBox(
            height: 200,
          ),
        ],
      ),
    );
  }

  // 初始化
  void initial() {
    setState(() {
      widget.controller._data = <RichEditData>[];
      widget.controller._data.add(RichEditData(
        RichEditDataType.TEXT,
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
    String textAfter = "";
    String textBefore = "";

    focusNodes.forEach((key, value) {
      if (value.hasFocus) {
        insertIndex = key + 1;
        TextEditingController textController = textControllers[key];
        textAfter = textController.selection.textAfter(textController.text);
        textBefore = textController.selection.textBefore(textController.text);
        widget.controller._data[key].data = textController.text.substring(0, textController.text.length - textAfter.length);
      }
    });

    switch (richEditData.type) {
      case RichEditDataType.IMAGE:
      case RichEditDataType.VIDEO:
      case RichEditDataType.TEXT:
        textBefore.isEmpty ? null : widget.controller._data.insert(insertIndex, richEditData);
        break;
      case RichEditDataType.NONE:
        insertIndex = insertIndex - 1;
        break;
    }

    textAfter.isEmpty
        ? null
        : widget.controller._data.insert(
            insertIndex + 1,
            RichEditData(
              RichEditDataType.TEXT,
              data: textAfter,
            ),
          );
    setState(() {});
  }
}
