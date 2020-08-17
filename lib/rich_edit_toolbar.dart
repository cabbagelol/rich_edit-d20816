// 富文本菜单

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rich_edit/rich_edit.dart';

export 'rich_edit_theme.dart';

enum RichEditToolbarType { TEXT, IMAGE, VIDEO, KEYBOARD, HR, CLEAR }

class RichEditToolbar extends StatefulWidget {
  // 工具集合
  final List<RichEditTool> children;

  // 控制器
  final RichEditController controller;

  RichEditToolbar(
    this.controller, {
    this.children,
  });

  @override
  _RichEditToolbarState createState() => _RichEditToolbarState();
}

class _RichEditToolbarState extends State<RichEditToolbar> {
  List _list = <RichEditTool>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _list = <RichEditTool>[];

    widget.children.forEach((RichEditTool e) {
      e.controller = widget.controller;

      if (e.type == RichEditToolbarType.KEYBOARD) {
        // TODO
      }

      _list.add(e);
    });

    return Row(
      children: _list,
    );
  }
}

// toolbar代理者
class RichEditTool extends StatelessWidget {
  final Widget child;

  RichEditController controller;

  RichEditToolbarType type;

  final int flex;

  final bool disable;

  RichEditTool({
    this.child,
    this.controller,
    this.type,
    this.flex = 0,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Opacity(
        opacity: disable ?? false ? 0.2 : 1,
        child: this.child,
      ),
    );
  }
}

// 文字
class RichEditToolText extends StatelessWidget implements RichEditTool {
  RichEditToolbarType type = RichEditToolbarType.TEXT;

  final Widget child;

  final Function onTap;

  final int flex;

  final bool disable;

  RichEditToolText({
    Widget child,
    Function onTap,
    int flex = 0,
    bool disable,
  })  : child = child ??
            IconButton(
              icon: Icon(
                Icons.text_fields,
                color: RichEditTheme().mainColor,
              ),
              tooltip: "新建文本",
            ),
        onTap = onTap ?? null,
        flex = flex ?? 0,
        disable = disable ?? false;

  @override
  Widget build(BuildContext context) {
    return RichEditTool(
      child: GestureDetector(
        onTap: () async {
          if (disable) {
            return;
          }

          controller.addView(
            RichEditData(RichEditDataType.TEXT, ""),
          );
        },
        child: this.child,
      ),
      flex: flex,
      disable: disable,
    );
  }

  @override
  var controller;
}

// 图像
class RichEditToolImages extends StatelessWidget implements RichEditTool {
  RichEditToolbarType type = RichEditToolbarType.IMAGE;

  final Widget child;

  final Function onTap;

  final int flex;

  final bool disable;

  RichEditToolImages({
    Widget child,
    Function onTap,
    this.flex,
    this.disable,
  })  : child = child ??
            IconButton(
              icon: Icon(
                Icons.image,
                color: RichEditTheme().mainColor,
              ),
              tooltip: "插入图片",
            ),
        onTap = onTap ?? null;

  @override
  Widget build(BuildContext context) {
    return RichEditTool(
      child: GestureDetector(
        onTap: () async {
          String path = await this.controller.addImage();

          if (path != null) {
            controller.addView(
              RichEditData(RichEditDataType.IMAGE, path),
            );
          }
        },
        child: this.child, //
      ),
      flex: flex,
      disable: disable,
    );
  }

  @override
  var controller;
}

// 多媒体
class RichEditToolVideo extends StatelessWidget implements RichEditTool {
  RichEditToolbarType type = RichEditToolbarType.VIDEO;

  final Widget child;

  final Function onTap;

  final int flex;

  final bool disable;

  RichEditToolVideo({
    Widget child,
    Function onTap,
    this.flex,
    this.disable,
  })  : child = child ??
            IconButton(
              icon: Icon(
                Icons.videocam,
                color: RichEditTheme().mainColor,
              ),
              tooltip: "插入视频",
            ),
        onTap = onTap ?? null;

  @override
  Widget build(BuildContext context) {
    return RichEditTool(
      child: GestureDetector(
        onTap: () async {
          String path = await this.controller.addVideo();

          if (path != null) {
            controller.addView(
              RichEditData(RichEditDataType.VIDEO, path),
            );
          }
        },
        child: this.child, //
      ),
      flex: flex,
      disable: disable,
    );
  }

  @override
  var controller;
}

// 清理文档内容
class RichEditToolClear extends StatelessWidget implements RichEditTool {
  final RichEditToolbarType type = RichEditToolbarType.CLEAR;

  final BuildContext context;

  final Color disabledColor;

  final Color color;

  final int flex;

  final bool disable;

  RichEditToolClear(
    this.context, {
    this.disabledColor,
    this.color,
    this.flex = 0,
    this.disable,
  });

  VoidCallback _onClearTap() {
    List list = controller.getDataList();

    if (list.length <= 1 && list[0].data.toString().length <= 0) {
      return null;
    } else if (list.length >= 1 || list[0].data.toString().length > 0) {
      return () {
        controller.initial();
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichEditTool(
      child: IconButton(
        disabledColor: disabledColor ?? Colors.black12,
        color: color ?? RichEditTheme().mainColor,
        icon: Icon(Icons.delete),
        onPressed: _onClearTap(),
      ),
      flex: flex,
      disable: disable,
    );
  }

  @override
  var controller;

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// 键盘开关
class RichEditToolKeyboardSwitch extends StatelessWidget implements RichEditTool, WidgetsBindingObserver {
  final RichEditToolbarType type = RichEditToolbarType.KEYBOARD;

  final BuildContext context;

  final Color disabledColor;

  final Color color;

  final int flex;

  final bool disable;

  bool stitc;

  RichEditToolKeyboardSwitch(
    this.context, {
    this.disabledColor,
    this.color,
    this.flex = 0,
    this.disable,
  });

  _getBtn1ClickListener() {
    if (!stitc) {
      return () {
        FocusScope.of(context).requestFocus(FocusNode());
      };
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext contextT) {
    stitc = MediaQuery.of(context).viewInsets.bottom == 0;

    return RichEditTool(
      child: IconButton(
        disabledColor: disabledColor ?? Colors.black12,
        color: color ?? RichEditTheme().mainColor,
        icon: Icon(
          !stitc ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
        ),
        onPressed: _getBtn1ClickListener(),
      ),
      flex: flex,
      disable: disable,
    );
  }

  @override
  var controller;

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// SizedBox
class RichEditToolSizedBox extends StatelessWidget implements RichEditTool {
  RichEditToolbarType type = RichEditToolbarType.HR;

  final num width;

  final int flex;

  final Widget child;

  final bool disable;

  RichEditToolSizedBox({
    this.width,
    this.child,
    this.flex,
    this.disable,
  });

  @override
  Widget build(BuildContext context) {
    return RichEditTool(
      child: SizedBox(
        width: width,
        child: child,
      ),
      flex: flex,
      disable: disable,
    );
  }

  @override
  var controller;

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
