import 'story_model.dart';

DateTime now = DateTime.now();
var data =
new DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);

final List<Story> stories = [
  Story(
    url:
    'images/tl.mp4',
    media: MediaType.videoAsset,
    duration: const Duration(seconds: 10),
    data: data
  ),
  Story(
    url:
    'https://images.unsplash.com/photo-1534103362078-d07e750bd0c4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
    media: MediaType.image,
    duration: const Duration(seconds: 10),
      data: data
  ),
  Story(
    url: 'https://media.giphy.com/media/moyzrwjUIkdNe/giphy.gif',
    media: MediaType.image,
    duration: const Duration(seconds: 7),
      data: data
  ),
  Story(
    url:
    'https://static.videezy.com/system/resources/previews/000/005/529/original/Reaviling_Sjusj%C3%B8en_Ski_Senter.mp4',
    media: MediaType.video,
    duration: const Duration(seconds: 0),
      data: data
  ),
  Story(
    url:
    'https://images.unsplash.com/photo-1531694611353-d4758f86fa6d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=564&q=80',
    media: MediaType.image,
    duration: const Duration(seconds: 5),
      data: data
  ),
  Story(
    url:
    'https://static.videezy.com/system/resources/previews/000/007/536/original/rockybeach.mp4',
    media: MediaType.video,
    duration: const Duration(seconds: 0),
      data: data
  ),
  Story(
    url: 'https://media2.giphy.com/media/M8PxVICV5KlezP1pGE/giphy.gif',
    media: MediaType.image,
    duration: const Duration(seconds: 8),
      data: data
  ),

  Story(
    url:
    'https://www.youtube.com/embed/u31qwQUeGuM',
    media: MediaType.video,
    duration: const Duration(seconds: 10),
      data: data
  ),
];