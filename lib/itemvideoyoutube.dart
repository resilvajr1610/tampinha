import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ItemVideoYoutube extends StatefulWidget {
  final String url;

  ItemVideoYoutube(this.url);

  @override
  _ItemVideoYoutubeState createState() => _ItemVideoYoutubeState();
}

class _ItemVideoYoutubeState extends State<ItemVideoYoutube> {
  bool curtiu = false;
  String? videoId;
  YoutubePlayerController? controller;

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      videoId = YoutubePlayer.convertUrlToId(widget.url);
      controllerYoutube(videoId);
    }
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  void controllerYoutube(videoId) {
    controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return item(controller, videoId, context);
  }

  Widget item(controller, videoId, context) {
    return GestureDetector(
      onTap: () async {
        if (kIsWeb) {
          var url = widget.url;
          if (await canLaunch(url) != null) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  height: 250.0,
                  child: (!kIsWeb)
                      ? YoutubePlayer(
                          key: ObjectKey(controller),
                          controller: controller,
                          actionsPadding: EdgeInsets.only(left: 16.0),
                          bottomActions: [
                            CurrentPosition(),
                            SizedBox(width: 10.0),
                            ProgressBar(isExpanded: true),
                            SizedBox(width: 10.0),
                            RemainingDuration(),
                            FullScreenButton(),
                          ],
                        )
                      : Container(
                          child: InkWell(
                            onTap: () async {
                              var url = widget.url;
                              if (await canLaunch(url) != null) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 250.0,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              'https://img.youtube.com/vi/$videoId/0.jpg'),
                                          fit: BoxFit.contain)),
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Center(
                                  child: Icon(Icons.play_arrow,
                                      color: Colors.white, size: 50),
                                )
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
