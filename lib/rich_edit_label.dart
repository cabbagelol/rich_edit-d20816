// 内置的标签

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'rich_edit.dart' show RichEditData;

class richEditLabel {
  richEditLabel();

  // widget Style转换为Html Style标准

  // 转换Html
  void generateTextHtml(StringBuffer sb, RichEditData element) {
    if (element.data != "") {
      sb.write("<p>");
      sb.write(element.data);
      sb.write("<\/p>");
    }
  }

  // 文本
  static Widget P(
    context,
    index,
    focusNodes,
    textControllers,
    textStyle, {
    Function onChanged,
  }) {
    return Container(
      width: 10,
      margin: EdgeInsets.only(
        left: 15,
        top: 15,
      ),
      child: EditableText(
        controller: textControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.newline,
        autocorrect: false,
        enableSuggestions: false,
        backgroundCursorColor: Colors.transparent,
//        locale: Locale('CH'),
//        paintCursorAboveText: true,
        style: textStyle ??
            TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
        minLines: 1,
        maxLines: null,
        cursorColor: Color(0xff364e80),
        showSelectionHandles: true,
        enableInteractiveSelection: false,
        onChanged: (text) {
          onChanged(text);
        },
        onEditingComplete: () {
          print("onEditingComplete");
        },
        selectionHeightStyle: BoxHeightStyle.includeLineSpacingBottom,
        onSubmitted: (text) {
          print("onSubmitted");
        },
      ),
    );
  }

  // 图片
  static Widget IMG(
    child, {
    Function onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        children: <Widget>[
          child,
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                onChanged();
              },
            ),
          )
        ],
      ),
    );
  }
}
