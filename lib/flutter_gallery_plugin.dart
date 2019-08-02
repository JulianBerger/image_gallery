import 'dart:async';

import 'package:flutter/services.dart';

class ImageData {
  final String path;
  final location;
  final time;

  ImageData(this.path, this.location, this.time);
}

class FlutterGalleryPlugin {
  static const DATA_CHANNEL = 'flutter_gallery_plugin/data';

  static const _eventChannel = const EventChannel(DATA_CHANNEL);

  static Stream<dynamic> getPhotoData(
  ) {
    return _eventChannel.receiveBroadcastStream().cast<dynamic>();
  }
}
