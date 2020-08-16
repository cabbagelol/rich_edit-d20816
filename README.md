[![Pub](https://img.shields.io/pub/v/rich_edit.svg)](https://pub.flutter-io.cn/packages/rich_edit)


# rich_edit

flutter 富文本编辑器 支持图文、视频混排。

## TODO
· 可自定义标签渲染的widget。
· 自定义toolWidget
· 自定义richEdit Theme

## Getting Started

首先需要继承实现RichEditController。
简单使用可直接用下面的例子。

```yaml
  chewie: 0.9.10
  video_player: 0.10.11
  image_picker: 0.6.7
```

```dart
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rich_edit/rich_edit.dart';
import 'package:video_player/video_player.dart';

class SimpleRichEditController extends RichEditController {

  Map<String, ChewieController> controllers = Map();


  //添加视频方法
  @override
  Future<String> addVideo() async {
    var pickedFile = await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      //模拟上传后返回的路径
      return "http://static.fanghnet.com/uploads/szx/uploads/2020/06/353f2c48ce164e368cc040c4fb425331.mp4";
    }
    return null;
  }

  //添加图片方法
  @override
  Future<String> addImage() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      //模拟上传后返回的路径
      return "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1592205365009&di=fcc201c596fc6681fe7812aa7fea4b23&imgtype=0&src=http%3A%2F%2Fa3.att.hudong.com%2F14%2F75%2F01300000164186121366756803686.jpg";
    }
    return null;
  }

  //生成视频view方法
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

 //生成图片view方法
  @override
  Widget generateImageView(RichEditData data) =>
      Image.network(data.data, height: 200, width: 300);
}
```

使用
```dart
RichEdit(SimpleRichEditController());
```

SimpleRichEditController 方法

| 方法名              | 作用                                           |
| ------------------- | ---------------------------------------------- |
| generateHtml()      | 将内容转换为html                               |
| generateTextHtml()  | 生成的文本html，可使用 override 自定义生成模版 |
| generateImageHtml() | 生成的图片html                                 |
| generateVideoHtml() | 生成的视频html                                 |
| getDataList()       | 获取内容数据集                                 |



