import 'dart:io';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:path/path.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tampinha/design.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:tampinha/models/connectToDB.dart';
import 'package:tampinha/models/story_model.dart';
import 'package:video_player/video_player.dart';

import '../layout.dart';
import '../main.dart';

class AdicionarStory extends StatefulWidget {
  final List<Story> stories;

  AdicionarStory(this.stories);

  @override
  _AdicionarStoryState createState() => _AdicionarStoryState();
}

class _AdicionarStoryState extends State<AdicionarStory> {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _urlController = TextEditingController();
  int? valorAtualTipoInput;
  List<int> listaId = [];
  VideoPlayerController? _controllerVideo;
  Future<void>? _initializeVideoPlayerFuture;
  File? imagemGaleria, pdfapp, imagemcamera, videoapp;
  double progress = 0.0;
  bool isUploading = false;
  List<Story> allStoriesToBeDeleted = [];

  bool enviarlinkyoutube = false;
  int selectedValue = 0;

  FirebaseStorage storage = FirebaseStorage.instance;

  Map<int, Widget> childrenSegmented = {
    0: Text(
      'Adicionar link do Youtube ou GIPHY',
      textAlign: TextAlign.center,
      style: TextStyle(fontFamily: 'Hind', fontWeight: FontWeight.w500),
    ),
    1: Text(
      'Adicionar mídia da galeria',
      textAlign: TextAlign.center,
      style: TextStyle(fontFamily: 'Hind', fontWeight: FontWeight.w500),
    ),
    2: Text(
      'Apagar histórias',
      textAlign: TextAlign.center,
      style: TextStyle(fontFamily: 'Hind', fontWeight: FontWeight.w500),
    ),
  };

  Future<void> actionAdicionarHistoria(String url) async {
    await InsertIntoAppVideo(url);
  }

  Future<void> InsertIntoAppVideo(String url) async {
    showLoaderDialog(this.context, 'Adicionando...');
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    var conn = await mysql.MySqlConnection.connect(settings);

    DateTime now = DateTime.now();
    var data =
        new DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);

    print(_textEditingController.text);

    var getId = await conn.query('select id from app_video');

    for (var row in getId) {
      if (row[0] != null) {
        listaId.add(row[0]);
      }
    }
    listaId.sort();
    print(listaId);

    int lastId = listaId.isNotEmpty ? listaId.last + 1 : 0 + 1;

    var result = await conn.query(
        'insert into app_video (id, url, datahora, ativo)  values (?, ? , ?, ? )',
        [lastId, url, data, 1]);
    await conn.close();

    retornarParaHome();
  }

  Future<void> deleteFromImagesTable() async {
    showCupertinoDialog(
        context: this.context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text('Tem certeza?'),
            content:
                new Text('Todos as histórias serão deletadas definitivamente.'),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.amber),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(
                    "Confirmar",
                    style: TextStyle(color: Colors.amber),
                  ),
                  onPressed: () => deleteFromStorageAndTableFunction()),
            ],
          );
        });
  }

  Future<void> dialogMostRecentStory() async {
    showCupertinoDialog(
        context: this.context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text('Tem certeza?'),
            content: new Text(
                'A história mais recente será apagada permanentemente.'),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.amber),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(
                    "Confirmar",
                    style: TextStyle(color: Colors.amber),
                  ),
                  onPressed: () => deleteMostRecentMedia()),
            ],
          );
        });
  }

  Future<void> deleteFromStorageAndTableFunction() async {
    Navigator.pop(this.context);
    showLoaderDialog(this.context, 'Apagando...');
    try {
      SQL sql = SQL();

      await sql.connectToDB();

      var result = await sql.getConn().query('DELETE FROM app_video');

      await sql.closeConnection();

      for (Story s in widget.stories) {
        if (s.media != MediaType.youtube && (!s.url.contains('.gif'))) {
          print(s);
          Reference  mediaRef = await FirebaseStorage.instance.refFromURL(s.url);
          await mediaRef
              .delete()
              .then((value) => print(s.toString() + ' apagado'));
        }
      }
    } catch (e) {
      print(e.toString());
    } finally {
      retornarParaHome();
    }
  }

  Future<void> deleteMostRecentMedia() async {
    print('chamou');
    Navigator.pop(this.context);
    showLoaderDialog(this.context, 'Apagando...');
    Story lastStory = widget.stories.first;
    try {
      if (lastStory.media != MediaType.youtube &&
          !lastStory.url.contains('.gif')) {
        Reference  mediaRef = await FirebaseStorage.instance.refFromURL(lastStory.url);

        if (mediaRef != null) {
          await mediaRef
              .delete()
              .then((value) => print(lastStory.url + ' apagado'))
              .catchError((e) => print(e.toString()));
        }
      }
    } catch (e) {
      print(e.toString());
    } finally {
      SQL sql = SQL();

      await sql.connectToDB();

      var delete = await sql.getConn().query(
          'DELETE  FROM app_video WHERE ativo = 1 ORDER BY datahora DESC LIMIT 1');

      await sql.closeConnection();

      retornarParaHome();
    }
  }

  void retornarParaHome() {
    Navigator.of(this.context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyHomePage(title: '',)),
        (Route<dynamic> route) => false);
  }

  showLoaderDialog(BuildContext context, String texto) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7),
              child: Text(texto,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Hind', fontWeight: FontWeight.w500))),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _urlController?.dispose();
    _controllerVideo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/fundo2.png"),
                      fit: BoxFit.cover)),
            ),
            SafeArea(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Hero(
                    tag: 'logo',
                    child: Layout().logoextendido(
                        "images/logo.png",
                        MediaQuery.of(context).size.height * 0.16,
                        1.0,
                        context),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                          child: Column(
                        children: [
                          CupertinoSegmentedControl(
                              selectedColor: CupertinoColors.activeOrange,
                              unselectedColor: CupertinoColors.systemGrey5,
                              children: childrenSegmented,
                              groupValue: selectedValue,
                              pressedColor: CupertinoColors.destructiveRed,
                              onValueChanged: (int value) {
                                setState(() {
                                  selectedValue = value!;
                                });
                              }),
                          SizedBox(height: 20),
                          selectedValue == 0
                              ? insertLinkFromInternet()
                              : selectedValue == 1
                                  ? insertMediaFromDevice()
                                  : widgetApagarHistorias()
                        ],
                      )),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[],
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Column widgetApagarHistorias() {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () => widget.stories.isNotEmpty
                ? deleteFromImagesTable()
                : print('vazio'),
            child: Text('Apagar histórias',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Hind', fontWeight: FontWeight.w500))),
        ElevatedButton(
            onPressed: () => widget.stories.isNotEmpty
                ? dialogMostRecentStory()
                : print('vazio'),
            child: Text('Apagar a história mais recente',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Hind', fontWeight: FontWeight.w500))),
        ElevatedButton(
            onPressed: () => widget.stories.isNotEmpty
                ? modalDeleteFromURL(this.context)
                : print('vazio'),
            child: Text('Apagar a história baseado em URL',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Hind', fontWeight: FontWeight.w500)))
      ],
    );
  }

  Widget ExpansionTileTypeOfInput() {
    ThemeData theme = ThemeData();
    return Row(
      children: [
        Expanded(
          child: ExpansionTile(
            collapsedBackgroundColor: Colors.amber,
            textColor: Colors.red,
            collapsedIconColor: Colors.red,
            iconColor: Colors.red,
            initiallyExpanded: false,
            title: Layout().textosimples(
                'Qual o tipo de conteúdo que deseja inserir?',
                18.0,
                FontWeight.normal,
                1.0,
                Colors.black,
                Colors.transparent),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio(
                        value: TipoInputStory.IMAGE_FROM_NETWORK,
                        groupValue: valorAtualTipoInput,
                        onChanged: (int? value) {
                          setState(() {
                            valorAtualTipoInput = value!;
                          });
                        },
                      ),
                      Layout().textosimples(
                          'Imagem da internet (URL)',
                          18.0,
                          FontWeight.normal,
                          1.0,
                          Colors.black,
                          Colors.transparent),
                    ],
                  ),
                  Divider(
                    thickness: 2.0,
                    color: Colors.white,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio(
                        value: TipoInputStory.VIDEO_FROM_NETWORK,
                        groupValue: valorAtualTipoInput,
                        onChanged: (int? value) {
                          setState(() {
                            valorAtualTipoInput = value!;
                          });
                        },
                      ),
                      Layout().textosimples(
                          'Vídeo da internet/GIF (URL)',
                          18.0,
                          FontWeight.normal,
                          1.0,
                          Colors.black,
                          Colors.transparent),
                    ],
                  ),
                  Divider(
                    thickness: 2.0,
                    color: Colors.white,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget insertLinkFromInternet() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(labelText: 'Insira o url...'),
            controller: _textEditingController,
            keyboardType: TextInputType.url,
            onChanged: (value) {
              if (value.contains('mp4') && !value.contains('youtu')) {
                print('aqui');
                _controllerVideo = VideoPlayerController.network(value)
                  ..initialize().then((_) {
                    // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                    setState(() {});
                  });
                _initializeVideoPlayerFuture = _controllerVideo?.initialize();
              }
            },
          ),
        ),
        SizedBox(height: 20.0),
        _textEditingController.text.isNotEmpty
            ? ElevatedButton(
                onPressed: () =>
                    actionAdicionarHistoria(_textEditingController.text),
                child: Text('Adicionar história'))
            : Container(),
        SizedBox(height: 20.0),
        _textEditingController.text.isNotEmpty &&
                !_textEditingController.text.contains('mp4') &&
                !_textEditingController.text.contains('youtu')
            ? CachedNetworkImage(
                height: 175,
                width: 175,
                imageUrl: _textEditingController.text,
                placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.yellow,
                    child: Image.asset('images/logo.png')),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
            : futureVideoPlayer(),
      ],
    );
  }

  Widget insertMediaFromDevice() {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () => modalbottom(this.context),
            child: Text(
                checkIfMediaIsNull()
                    ? 'Adicionar mídia do aparelho'
                    : 'Escolher outra mídia',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Hind', fontWeight: FontWeight.w500))),
        SizedBox(height: 10),
        imagemcamera != null
            ? isUploading
                ? CircularProgressLiquid()
                : containerFile(imagemcamera!)
            : Container(),
        imagemGaleria != null
            ? isUploading
                ? CircularProgressLiquid()
                : containerFile(imagemGaleria!)
            : Container(),
        SizedBox(height: 15),
        imagemcamera != null && !isUploading
            ? ElevatedButton(
                onPressed: () => salvarFirebaseStorage(imagemcamera!),
                child: Text('Adicionar mídia as histórias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Hind', fontWeight: FontWeight.w500)))
            : Container(),
        imagemGaleria != null && !isUploading
            ? ElevatedButton(
                onPressed: () => salvarFirebaseStorage(imagemGaleria!),
                child: Text('Adicionar mídia as histórias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Hind', fontWeight: FontWeight.w500)))
            : Container(),
        videoapp != null
            ? isUploading
                ? CircularProgressLiquid()
                : ElevatedButton(
                    onPressed: () => salvarFirebaseStorage(videoapp!),
                    child: Text('Adicionar mídia as histórias',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Hind', fontWeight: FontWeight.w500)))
            : Container(),
      ],
    );
  }

  Container CircularProgressLiquid() {
    return Container(
      width: 150,
      height: 150,
      child: LiquidCircularProgressIndicator(
          backgroundColor: Colors.white,
          value: progress / 100,
          valueColor: AlwaysStoppedAnimation(Colors.amber),
          direction: Axis.vertical,
          center: Text(
            "$progress%",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )),
    );
  }

  bool checkIfMediaIsNull() {
    if (imagemcamera == null && imagemGaleria == null && videoapp == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> salvarFirebaseStorage(File file) async {
    DateTime now = DateTime.now();
    var data =
        new DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);

    if (file != null) {
      String pathString = basename(file.path) + data.toIso8601String();
      var storageRefImages = this.storage.ref().child('historias/$pathString');

      if (file == videoapp) {
        String pathStringVideo =
            basename(file.path) + data.toIso8601String() + 'mp4';

        var storageRefVideo =
            this.storage.ref().child('historias/$pathStringVideo');
        UploadTask  uploadTask = storageRefVideo.putFile(file, SettableMetadata(contentType: 'video/mp4'));
        uploadTask.snapshotEvents.listen((event) {
          setState(() {
            isUploading = true;
            progress = ((event.bytesTransferred / event.totalBytes) * 100).roundToDouble();
            print(progress);
          });
        });
        await uploadTask;
        if (uploadTask.snapshot.state == TaskState.success) {
          // O upload foi bem-sucedido, agora você pode obter a URL de download.
          String downloadURL = await storageRefVideo.getDownloadURL();
          actionAdicionarHistoria(downloadURL);
        } else {
          // O upload falhou, lide com o erro aqui.
          print('Erro durante o upload: ');
        }
      } else {
        print('entrou else');
        UploadTask  uploadTask = storageRefImages.putFile(file);
        uploadTask.snapshotEvents.listen((event) {
          setState(() {
            isUploading = true;
            progress = ((event.bytesTransferred.toDouble() /event.totalBytes) * 100)
                .roundToDouble();
            print(progress);
          });
        });
        await uploadTask;
        if (uploadTask.snapshot.state == TaskState.success) {
          // O upload foi bem-sucedido, agora você pode obter a URL de download.
          String downloadURL = await storageRefImages.getDownloadURL();
          actionAdicionarHistoria(downloadURL);
        } else {
          // O upload falhou, lide com o erro aqui.
          print('Erro durante o upload: ');
        }
      }
    }
  }

  Container containerFile(File file) {
    return Container(
        height: MediaQuery.of(this.context).size.height * 0.4,
        width: MediaQuery.of(this.context).size.height * 0.4,
        child: Image.file(file));
  }

  void modalbottom(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text('Câmera'),
                    onTap: () {
                      Navigator.pop(context);
                      tirarfoto();
                    }),
                ListTile(
                    leading: new Icon(Icons.photo),
                    title: new Text('Galeria de Fotos'),
                    onTap: () {
                      Navigator.pop(context);
                      pegarimagens();
                    }),
                ListTile(
                  leading: new Icon(Icons.videocam),
                  title: new Text('Video'),
                  onTap: () {
                    Navigator.pop(context);
                    pegarvideo();
                  },
                ),
              ],
            ),
          );
        });
  }


  void modalDeleteFromURL(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height * 1.0,
            child: Wrap(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Insira o url...'),
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  onSubmitted: (value) => actionDeleteFromURL(value),
                 )
              ],
            ),
          );
        });
  }

  Future<void> actionDeleteFromURL(String url) async {
    showLoaderDialog(this.context, 'Apagando...');

    String urlToDelete = url;

    try {
      SQL sql = SQL();

      await sql.connectToDB();

      var result = await sql.getConn().query('DELETE FROM app_video where url = ?', [urlToDelete]);

      await sql.closeConnection();


      retornarParaHome();

    } catch (e) {
      print(e.toString());
    }
  }

  Future tirarfoto() async {
    setState(() {
      imagemcamera = null;
      imagemGaleria = null;
      videoapp = null;
    });
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 600,
        maxHeight: 600);
    setState(() {
      imagemcamera = File(image!.path);
    });
  }

  Future<void> pegarimagens() async {
    if (!kIsWeb) {
      try {
        setState(() {
          imagemcamera = null;
          imagemGaleria = null;
          videoapp = null;
        });
        var image = await ImagePicker().pickImage(source: ImageSource.gallery);
        File imageFile = File(image!.path);
        setState(() {
          imagemGaleria = imageFile;
        });
      } on Exception catch (e) {}
      if (!mounted) return;
    }
  }

  Future pegarvideo() async {
    setState(() {
      imagemcamera = null;
      imagemGaleria = null;
      videoapp = null;
    });
    var video = await ImagePicker().pickVideo(
        source: ImageSource.gallery, maxDuration: Duration(minutes: 15));
    File videofile = File(video!.path);
    setState(() {
      videoapp = videofile;
    });
  }

  Widget futureVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the video.
          return AspectRatio(
            aspectRatio: _controllerVideo!.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(_controllerVideo!),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return Container();
        }
      },
    );
  }
}
