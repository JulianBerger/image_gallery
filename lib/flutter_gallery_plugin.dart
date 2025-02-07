import 'dart:async';

import 'package:flutter/services.dart';

class ImageLocation {
  final num lat;
  final num lon;

  ImageLocation(this.lat, this.lon);
}

class ImageData {
  final String path;
  final ImageLocation location;
  final num timestamp;

  get date => new DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);

  ImageData(this.path, this.location, this.timestamp);
}

class FlutterGalleryPlugin {
  static const DATA_CHANNEL = 'flutter_gallery_plugin/data';

  static const _eventChannel = const EventChannel(DATA_CHANNEL);

  static ImageData _toImageData(dynamic map) {
  if (map is Map) {
    ImageLocation location = new ImageLocation(map['location']['lat'], map['location']['lon']);
    return new ImageData(map['path'], location,  map['time']);
  }
  return null;
  }

  static Stream<ImageData> getPhotoData(
  ) {
    return _eventChannel.receiveBroadcastStream().map(_toImageData);
  }
}
