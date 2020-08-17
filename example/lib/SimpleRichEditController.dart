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
    var pickedFile = await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      return "http://static.fanghnet.com/uploads/szx/uploads/2020/06/353f2c48ce164e368cc040c4fb425331.mp4";
    }
    return null;
  }

  @override
  Future<String> addImage() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1592205365009&di=fcc201c596fc6681fe7812aa7fea4b23&imgtype=0&src=http%3A%2F%2Fa3.att.hudong.com%2F14%2F75%2F01300000164186121366756803686.jpg";
    }
    return null;
  }

  @override
  Widget generateVideoView(RichEditData data) {
    if (!controllers.containsKey(data.data)) {
      var controller = ChewieController(
        videoPlayerController: VideoPlayerController.network(data.data),
        autoPlay: false,
        autoInitialize: true,
        aspectRatio: 16 / 9,
        looping: false,
        showControls: true,
        // 占位图
        placeholder: new Container(
          color: Colors.grey,
        ),
      );
      controllers[data.data] = controller;
    }
    var video = Chewie(
      controller: controllers[data.data],
    );
    return video;
  }

  @override
  Widget generateImageView(RichEditData data) =>
      Image.network(data.data, height: 200, width: 300);
}

