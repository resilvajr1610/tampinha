
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import 'layout.dart';



class ItemVideoEscolaDetalhe extends StatefulWidget {



  ItemVideoEscolaDetalhe();

  @override
  _ItemVideoEscolaDetalheState createState() => _ItemVideoEscolaDetalheState();
}

class _ItemVideoEscolaDetalheState extends State<ItemVideoEscolaDetalhe> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('images/tl.mp4')
          ..initialize().then((_) {
            _controller!.play();
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Hero(
              tag: 'logo',
              child: Layout().logoextendido("images/logo.png",
                  MediaQuery.of(context).size.height * 0.16, 1.0, context),
            ),
          ),


          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : SizedBox(
                  height: 220.0,
                  width: MediaQuery.of(context).size.width,
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 220.0,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                      )
                  ),
                ),
              ),
            ),
          ),

          Layout().botaosimples(text: 'Continuar', function: (){
            _controller!.pause();
            Navigator.pop(context);
          })
        ],
      ),
    );
  }
}
