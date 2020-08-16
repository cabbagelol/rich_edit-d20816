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

class Home extends StatelessWidget {
  SimpleRichEditController _richEditController = SimpleRichEditController();

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
        children: <Widget>[
          Expanded(
            flex: 1,
            child: RichEdit(
              _richEditController,
            ),
          ),
          RichEditToolbar(
            _richEditController,
            children: <RichEditTool>[
              RichEditToolText(),
              RichEditToolImages(),
              RichEditToolVideo(),
            ],
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
