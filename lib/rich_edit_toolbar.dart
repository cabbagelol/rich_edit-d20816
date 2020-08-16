// 富文本菜单

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rich_edit/rich_edit.dart';

export 'rich_edit_theme.dart';

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
    widget.children.forEach((RichEditTool e) {
      e.controller = widget.controller;
      _list.add(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _list,
    );
  }
}

// toolbar代理者
class RichEditTool extends StatelessWidget {
  final Widget child;

  RichEditController controller;

  RichEditTool({
    this.child,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return this.child;
  }
}

// 文字
class RichEditToolText extends StatelessWidget implements RichEditTool {
  final Widget child;

  final Function onTap;

  RichEditToolText({
    Widget child,
    Function onTap,
  })  : child = child ??
            IconButton(
              icon: Icon(
                Icons.text_fields,
                color: RichEditTheme().mainColor,
              ),
            ),
        onTap = onTap ?? null;

  @override
  Widget build(BuildContext context) {
    return RichEditTool(
      child: GestureDetector(
        onTap: () async {
          controller.addView(
            RichEditData(RichEditDataType.TEXT, "测试"),
          );
        },
        child: this.child, //
      ),
    );
  }

  @override
  var controller;
}

// 图像
class RichEditToolImages extends StatelessWidget implements RichEditTool {
  final Widget child;

  final Function onTap;

  RichEditToolImages({
    Widget child,
    Function onTap,
  })  : child = child ??
            IconButton(
              icon: Icon(
                Icons.image,
                color: RichEditTheme().mainColor,
              ),
            ),
        onTap = onTap ?? null;

  @override
  Widget build(BuildContext context) {
    print(controller);
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
    );
  }

  @override
  var controller;
}

// 多媒体
class RichEditToolVideo extends StatelessWidget implements RichEditTool {
  final Widget child;

  final Function onTap;

  RichEditToolVideo({
    Widget child,
    Function onTap,
  })  : child = child ??
      IconButton(
        icon: Icon(
          Icons.videocam,
          color: RichEditTheme().mainColor,
        ),
      ),
        onTap = onTap ?? null;

  @override
  Widget build(BuildContext context) {
    print(controller);
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
    );
  }

  @override
  var controller;
}