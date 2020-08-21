import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:video_player/video_player.dart';

class SimpleRichEditController extends RichEditController {
  Map<String, ChewieController> controllers = Map();

  final context;

  final theme;

  SimpleRichEditController(this.context, {this.theme});

  @override
  Future<String> addVideo() async {
    return "http://static.fanghnet.com/uploads/szx/uploads/2020/06/353f2c48ce164e368cc040c4fb425331.mp4";
  }

  @override
  Future<String> addImage() async {
    return "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1592205365009&di=fcc201c596fc6681fe7812aa7fea4b23&imgtype=0&src=http%3A%2F%2Fa3.att.hudong.com%2F14%2F75%2F01300000164186121366756803686.jpg";
  }

  @override
  Widget generateImageView(RichEditData data) {
    return Image.network(
      data.data,
      fit: BoxFit.fitWidth,
    );
  }
}
