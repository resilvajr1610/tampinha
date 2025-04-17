import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tampinha/design.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/story_model.dart';

class Stories extends StatefulWidget {
  final List<Story> stories;

  const Stories({required this.stories});

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> with SingleTickerProviderStateMixin {
  PageController? _pageController;
  VideoPlayerController? _videoPlayerController;
  int _currentIndex = 0;
  AnimationController? _aniController;
  String? videoId;
  YoutubePlayerController? _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    _aniController = AnimationController(vsync: this);
    _pageController = PageController();
    _booleanSetMarcarComoVisto();
    final Story firstStory = widget.stories.first;
    _loadStory(story: firstStory, animateToPage: false);
    _aniController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _aniController!.stop();
        _aniController!.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex += 1;
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            _currentIndex = 0;
            _loadStory(story: widget.stories[_currentIndex]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController!.dispose();
    _aniController!.dispose();
    if (_youtubePlayerController != null && _youtubePlayerController!.value.isPlaying)
      _youtubePlayerController!.pause();
    _youtubePlayerController = null;
    _youtubePlayerController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  _booleanSetMarcarComoVisto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KeysSharedPrefs.VISUALIZACAO, true);
    bool? valor = prefs.getBool(KeysSharedPrefs.VISUALIZACAO);
    print(valor);
  }

  void controllerYoutube(videoId) {
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  void _loadStory({required Story story, bool animateToPage = true}) {
    _aniController!.stop();
    _aniController!.reset();
    switch (story.media) {
      case MediaType.image:
        _youtubePlayerController?.pause();
        _youtubePlayerController = null;
        _youtubePlayerController?.dispose();
        _videoPlayerController?.pause();
        _videoPlayerController = null;
        _videoPlayerController?.dispose();
        _aniController!.duration = story.duration;
        _aniController!.forward();
        break;
      case MediaType.video:
        _youtubePlayerController?.pause();
        _youtubePlayerController = null;
        _youtubePlayerController?.dispose();
        _videoPlayerController?.pause();
        _videoPlayerController = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.network(story.url)
          ..initialize().then((_) {
            setState(() {});
            if (_videoPlayerController!.value.isInitialized) {
              _aniController!.duration = _videoPlayerController!.value.duration;
              _videoPlayerController!.play();
              _aniController!.forward();
            }
          });
        break;
      case MediaType.videoAsset:
        _youtubePlayerController?.pause();
        _youtubePlayerController = null;
        _youtubePlayerController?.dispose();
        _videoPlayerController = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.asset(story.url)
          ..initialize().then((_) {
            setState(() {});
            if (_videoPlayerController!.value.isInitialized) {
              _aniController!.duration = _videoPlayerController!.value.duration;
              _videoPlayerController!.play();
              _aniController!.forward();
            }
          });
        break;
      case MediaType.youtube:
        _youtubePlayerController?.pause();
        _youtubePlayerController = null;
        _youtubePlayerController?.dispose();
        _videoPlayerController = null;
        _videoPlayerController?.dispose();
        videoId = YoutubePlayer.convertUrlToId(story.url);
        controllerYoutube(videoId);
        setState(() {});
        if (_youtubePlayerController!.value.isReady) {
          _youtubePlayerController!.play();
          _aniController!.duration = YoutubeMetaData().duration;
          _aniController!.forward();
        }
        print(_youtubePlayerController!.metadata.duration);
    }
    if (animateToPage) {
      _pageController!.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex += 1;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          _currentIndex = 0;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else {
      if (story.media == MediaType.video ||
          story.media == MediaType.videoAsset) {
        if (_videoPlayerController!.value.isPlaying) {
          _videoPlayerController!.pause();
          _aniController!.stop();
        } else {
          _videoPlayerController!.play();
          _aniController!.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.stories[_currentIndex];
    return WillPopScope(
     onWillPop: () async => false,
      child: story==null?Container():Scaffold(
          body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        child: Stack(
          children: [
            PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                itemCount: widget.stories.length,
                itemBuilder: (context, i) {
                  final Story story = widget.stories[i];
                  switch (story.media) {
                    case MediaType.image:
                      return CachedNetworkImage(
                          imageUrl: story.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey,
                              highlightColor: Colors.yellow,
                              child: Image.asset('images/logo.png')));
                      break;
                    case MediaType.video:
                      if (_videoPlayerController != null &&
                          _videoPlayerController!.value.isInitialized) {
                        return FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoPlayerController!.value.size.width,
                            height: _videoPlayerController!.value.size.height,
                            child: VideoPlayer(_videoPlayerController!),
                          ),
                        );
                      } else {
                        SizedBox.shrink(
                          child: Shimmer.fromColors(
                              baseColor: Colors.orange[300]!,
                              highlightColor: Colors.orange[100]!,
                              child: Image.asset('images/logo.png')),
                        );
                      }
                      break;
                    case MediaType.videoAsset:
                      if (_videoPlayerController != null &&
                          _videoPlayerController!.value.isInitialized) {
                        return AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!));
                      }
                      break;
                    case MediaType.youtube:
                      if (_youtubePlayerController != null) {
                        return Column(
                          children: [
                            Expanded(
                                child: Container(
                              color: Colors.black,
                            )),
                            Expanded(
                              child: YoutubePlayer(
                                aspectRatio: 16 / 9,
                                key: ObjectKey(_youtubePlayerController),
                                controller: _youtubePlayerController!,
                                actionsPadding: EdgeInsets.only(left: 16.0),
                                bottomActions: [
                                  CurrentPosition(),
                                  SizedBox(width: 10.0),
                                  ProgressBar(isExpanded: true),
                                  SizedBox(width: 10.0),
                                  RemainingDuration(),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Container(
                              color: Colors.black,
                            )),
                          ],
                        );
                      }
                      break;
                  }
                  return SizedBox.shrink(
                    child: Shimmer.fromColors(
                        baseColor: Colors.orange[300]!,
                        highlightColor: Colors.orange[100]!,
                        child: Image.asset('images/logo.png')),
                  );
                }),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: [
                  Row(
                    children: widget.stories
                        .asMap()
                        .map((i, e) {
                          return MapEntry(
                            i,
                            AnimatedBar(
                              animController: _aniController!,
                              position: i,
                              currentIndex: _currentIndex,
                            ),
                          );
                        })
                        .values
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical: 10.0,
                    ),
                    child: _youtubePlayerController==null?Container():UserInfo(
                      nome: 'Tampinha Legal',
                      data: story.data,
                      controller: _youtubePlayerController!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animController,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animController.value,
                            Colors.white,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final String nome;
  final DateTime data;
  final YoutubePlayerController controller;

  const UserInfo(
      {Key? key,
      required this.nome,
      required this.data,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 20.0,
          child: Hero(tag: 'logo', child: Image.asset('images/logo.png')),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    Shadow(
                      blurRadius: 8.0,
                      color: Color.fromARGB(125, 0, 0, 255),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.0),
              Text(
                getDataeHora(data),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    Shadow(
                      blurRadius: 8.0,
                      color: Color.fromARGB(125, 0, 0, 255),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
            icon: const Icon(
              Icons.close,
              size: 30.0,
              color: Colors.grey,
            ),
            onPressed: () {
              // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
              //     MyHomePage()), (Route<dynamic> route) => false);
              Navigator.pop(context);
            }),
      ],
    );
  }

  String getDataeHora(data) {
    String formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(data);
    return formattedDate;
  }
}
