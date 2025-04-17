import 'package:flutter/cupertino.dart';

enum MediaType { image, video, videoAsset, youtube}

class Story {
  final String url;
  final MediaType media;
  final Duration duration;
  final DateTime data;

  Story({required this.url, required this.media, required this.duration, required this.data});

  @override
  String toString() {
    return 'Story: {url: ${this.url}, MediaType: ${this.media}}, data : ${this.data.toString()}';
  }
}
