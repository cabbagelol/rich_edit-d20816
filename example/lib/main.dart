import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:rich_edit_example/SimpleRichEditController.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(
    MaterialApp(
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SimpleRichEditController _richEditController;

  @override
  void initState() {
    setState(() {
      _richEditController = SimpleRichEditController(
        context,
        theme: RichEditTheme(
          mainColor: Colors.amber,
        ),
      );

      /// 设置初始内容
      _richEditController.generateView(
        '<p>初始内容</p><p>我俩从昨晚 到现在 总是会时不时掉一个</p>',
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) {
                return Pre(
                  data: _richEditController.generateHtml(),
                );
              }));
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 可视视图
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xffffffff),
              child: RichEdit(
                _richEditController,
              ),
            ),
          ),

          // 工具栏
          Container(
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Colors.black12,
                ),
              ),
            ),
            child: RichEditToolbar(
              _richEditController,
              children: <RichEditTool>[
                // 添加文本
                RichEditToolText(
                  disable: false,
                ),
                // 添加图片
                RichEditToolImages(),
                // 添加媒体
                RichEditToolVideo(),
                // 空白容器
                RichEditToolSizedBox(
                  flex: 1,
                ),
                // 垃圾箱
                RichEditToolClear(context),
                //  键盘状态
                RichEditToolKeyboardSwitch(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _richEditController.controllers.forEach((key, value) {
      value.videoPlayerController.dispose();
      value.dispose();
    });
  }
}

class Pre extends StatelessWidget {
  final data;

  Pre({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String contentBase64 = base64Encode(const Utf8Encoder().convert(data));
    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: 'data:text/html;base64,$contentBase64',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
