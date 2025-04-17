import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tampinha/controllers/userlogin_controller.dart';
import 'package:tampinha/design.dart';
import 'package:tampinha/entidadesassistenciais.dart';
import 'package:tampinha/historias/addStory.dart';
import 'package:tampinha/itemvideo.dart';
import 'package:tampinha/mantenedores.dart';
import 'package:tampinha/notificacoes.dart';
import 'package:tampinha/numerosestado.dart';
import 'package:tampinha/pesagem/pesagem.dart';
import 'package:tampinha/pontosdecoleta.dart';
import 'package:tampinha/saibamais.dart';
import 'package:tampinha/historias/stories.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controllers/mysql_conexao.dart';
import 'layout.dart';
import 'models/connectToDB.dart';
import 'models/story_model.dart';
import 'notificacoesadd.dart';
import 'dart:io';

//Senha Admin
// master3
// y7ojw923s



// Android (key.properties, manifest nome, e package name, pubspec - versao)
// Android > app > main > java > configurar SDK
// flutter clean
// flutter pub get
// flutter pub run build_runner watch --delete-conflicting-outputs
// criar icones: flutter packages pub run flutter_launcher_icons:main
// testar
// flutter build apk --split-per-abi

// ios
// flutter clean
// flutter pub get
// flutter packages pub run flutter_launcher_icons:main
// xCode Runner (bundle, version, build), Sigin (Team, Push), Info (Nome, permissões), new file swift,
// arquivo Firebase, icone 1024
// Fecha workspace Podfile : platform: iOS, 9.0 , use_frameworks!
// cd ios > pod deintegrate
// pod install
// pod update
// testar
// fechar Xcode
// flutter clean
// flutter pub get
// flutter build ios

class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient( context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  HttpOverrides.global = new PostHttpOverrides();
  enableLogsInReleaseMode();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

void enableLogsInReleaseMode() {
  assert(() {
    // Em modo de depuração, os logs funcionam normalmente.
    return true;
  }());

  // Em modo de lançamento, os logs são ativados temporariamente.
  if (kDebugMode) {
    // O código a seguir será executado apenas no modo de depuração.
    print('Estou em modo de depuração.');
  } else {
    // O código a seguir será executado no modo de lançamento.
    print('Estou em modo de lançamento.');
  }
}

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  print('On background message $message');
  return Future<void>.value();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<UserLoginController>(
      create: (BuildContext context) => UserLoginController(),
      child: MaterialApp(
        title: 'Tampinha Legal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Tampinha Legal'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double ntampinhas = 0, valor = 0.0, peso = 0.0;
  String sobre='';
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Map<int, List<dynamic>> notificacoes = Map();
  Map<String, String> patrocinadores = Map();
  List<String> patrocinadoresimagem = [];
  List<String> estados = [];
  final formatCurrency = new NumberFormat.simpleCurrency(locale: 'pt_BR');
  final formatter = NumberFormat("###,###.### kg", "pt-br");
  final formattern = NumberFormat("###,###", "pt-br");
  AnimationController? controller;

  bool statusVisualizacao = false;

  List<Story> allStories = [];

  Future<List<Story>>? storiesFuturos;

  bool finishedStoriesSearch = false;

  Animation<double>? animation, animation2, animation3;
  static const Duration _duration = Duration(seconds: 1);
  var user;

  UserLoginController? userLoginController;

  final kInnerDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.redAccent),
    borderRadius: BorderRadius.circular(32),
  );

  final kGradientBoxDecoration = BoxDecoration(
    gradient: LinearGradient(colors: [Colors.black, Colors.redAccent]),
    border: Border.all(
      width: 0.5,
      color: Colors.red,
    ),
    borderRadius: BorderRadius.circular(32),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userLoginController = Provider.of<UserLoginController>(context);
  }

  conectardb(conn) async {
    var bannerdb = await conn.query('select imgurl, linkurl from app_banner where ativo = 1');
    for (var row in bannerdb) {
      patrocinadoresimagem.add(row[0]);
      patrocinadores[row[0]] = row[1];
    }
    print(patrocinadoresimagem.toString());
    var tampometrodb = await conn.query('select SUM(ntampinhas), SUM(valor), SUM(peso) from app_tampometro');
    for (var row in tampometrodb) {
      setState(() {
        ntampinhas = row[0];
        valor = row[1];
        peso = row[2];
      });
    }

    if (valor >= 900000 && valor <= 1500000) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ItemVideoEscolaDetalhe()));
    }

    var sobredb = await conn.query('select textoSobre from app_sobre');
    for (var row in sobredb) {
      setState(() {
        sobre = row[0].toString();
      });
    }

    animation = Tween(begin: 0.0, end: ntampinhas).animate(controller!);
    animation2 = Tween(begin: 0.0, end: valor).animate(controller!);
    animation3 = Tween(begin: 0.0, end: peso).animate(controller!);
    controller!.forward();

    await conn.close();

  }

  Future<List<Story>> pegarStories() async {
    var settings = new ConnectionSettings(
      host: MysqlConexao().url,
      port: MysqlConexao().porta,
      user: MysqlConexao().login,
      password: MysqlConexao().senha,
      db: MysqlConexao().db,
    );
    var conn = await MySqlConnection.connect(settings);
    List<Story> lista = [];
    var images = await conn.query('SELECT * FROM app_video WHERE ativo = 1 ORDER BY datahora DESC');
    // var images = await conn.getConn().query('SELECT * FROM app_video WHERE ativo = 1 ORDER BY datahora DESC');

    for (var row in images) {
      if (row.fields['url'].toString().contains('mp4')) {
        Story story = new Story(
            url: row.fields['url'],
            duration: const Duration(seconds: 8),
            media: MediaType.video,
            data: row.fields['datahora']);

        setState(() {
          lista!.add(story);
          allStories.add(story);
        });
      } else if (row.fields['url'].toString().contains('youtu')) {
        Story story = new Story(
            url: row.fields['url'],
            duration: const Duration(seconds: 8),
            media: MediaType.youtube,
            data: row.fields['datahora']);

        setState(() {
          lista!.add(story);
          allStories.add(story);
        });
      } else {
        Story story = new Story(
            url: row.fields['url'],
            duration: const Duration(seconds: 8),
            media: MediaType.image,
            data: row.fields['datahora']);
        //print(story.toString());
        setState(() {
          lista!.add(story);
          allStories.add(story);
        });
      }
    }
    await _intPegarQuantidadeDeStories();

    setState(() {});
    conectardb(conn);
    return lista;
  }

  @override
  void initState() {
    super.initState();
    storiesFuturos = pegarStories();
    recebernotificacoes();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    pegarStories();
    _savedevicetoken();
    controller = AnimationController(vsync: this, duration: _duration)
      ..addListener(() {
        setState(() {});
      });
  }

  _intPegarQuantidadeDeStories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int getQuantityOfStoriesDB = allStories.length;
    //print('quantidade real do sql:' + getQuantityOfStoriesDB.toString());
    int getQuantityOfStoriesShared =(prefs.getInt(KeysSharedPrefs.QTD_STORIES) ?? 0);


    //caso haja mais stories do que da ultima vez que o app foi aberto
    //os stories aparecerão para o usuário.
    if (getQuantityOfStoriesDB > getQuantityOfStoriesShared) {
      await prefs.setBool(KeysSharedPrefs.VISUALIZACAO, false);
      bool? status = prefs.getBool(KeysSharedPrefs.VISUALIZACAO);
      setState(() {
        statusVisualizacao = status!;
      });
    } else {
      bool? status = prefs.getBool(KeysSharedPrefs.VISUALIZACAO);
      setState(() {
        statusVisualizacao = status!;
      });
    }

    await prefs.setInt(KeysSharedPrefs.QTD_STORIES, getQuantityOfStoriesDB);
  }

  _savedevicetoken() async {
    _fcm.subscribeToTopic('tampinhalegal');
  }

  recebernotificacoes() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      novanotificacao(message.data);
    });

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Notificacoes()),
      );
    });
  }

  Widget? novanotificacao(message) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text('Nova Notificação!'),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Ver Agora",
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Notificacoes()));
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    controller!.dispose();
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
      drawer: Drawer(
        child: opcoesdrawer(this.context),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/fundo2.png"), fit: BoxFit.cover)),
          ),
          SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.001),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                child: Hero(
                  tag: 'logo',
                  child: Layout().logoextendido("images/logo.png",
                      MediaQuery.of(context).size.height * 0.16, 1.0, context),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Layout().textosimples(
                      "Patrocínio",
                      MediaQuery.of(context).size.height * 0.005,
                      FontWeight.normal,
                      -0.5,
                      Colors.black,
                      Colors.transparent),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: Swiper(
                      itemHeight: (MediaQuery.of(context).size.width ~/ 6).toDouble(),
                      itemWidth: (MediaQuery.of(context).size.width ~/ 33).toDouble(),
                      itemCount: patrocinadoresimagem.length,
                      itemBuilder: (context,index) {
                        return new GestureDetector(
                            child: (ModalRoute.of(context)!.isCurrent)
                                ? Image.network(
                                    "https://www.tampinhalegal.com.br/sistema" +
                                        patrocinadoresimagem[0]
                                            .replaceAll("..", ""),
                                    fit: BoxFit.contain,
                                  )
                                : Container(),
                            onTap: () async {
                              var url = patrocinadores[patrocinadoresimagem[0]];
                              if (await canLaunch(url!)) {
                                await launch(url);
                              } else {
                                throw 'Não foi possível acessar $url';
                              }
                            });
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Layout().textosimples(
                      "Tampômetro",
                      MediaQuery.of(context).size.height * 0.018,
                      FontWeight.normal,
                      -0.2,
                      Colors.black,
                      Colors.transparent),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Layout().textosimples(
                          formattern.format(
                              (animation != null) ? animation!.value : 0),
                          MediaQuery.of(context).size.height * 0.035,
                          FontWeight.bold,
                          0.0,
                          Colors.black,
                          Colors.transparent),
                      Layout().textosimples(
                          "tampinhas recicladas",
                          MediaQuery.of(context).size.height * 0.018,
                          FontWeight.normal,
                          0.0,
                          Colors.black,
                          Colors.transparent),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.004,
                  ),
                  Layout().textosimples(
                      "correspondentes a ",
                      MediaQuery.of(context).size.height * 0.018,
                      FontWeight.normal,
                      -0.2,
                      Colors.black,
                      Colors.transparent),
                  Layout().textosimples(
                      formatter
                          .format((animation3 != null) ? animation3!.value : 0),
                      MediaQuery.of(context).size.height * 0.03,
                      FontWeight.bold,
                      0.0,
                      Colors.black,
                      Colors.transparent),
                  Layout().textosimples(
                      "de material coletado",
                      MediaQuery.of(context).size.height * 0.018,
                      FontWeight.normal,
                      -0.2,
                      Colors.black,
                      Colors.transparent),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.004),
                  Layout().textosimples(
                      "que se transformaram em",
                      MediaQuery.of(context).size.height * 0.018,
                      FontWeight.normal,
                      -0.2,
                      Colors.black,
                      Colors.transparent),
                  Layout().textosimples(
                      formatCurrency
                          .format((animation2 != null) ? animation2!.value : 0),
                      MediaQuery.of(context).size.height * 0.03,
                      FontWeight.bold,
                      0.0,
                      Colors.red[700],
                      Colors.transparent),
                  Layout().textosimples(
                      "destinados 100% para entidades\nassistenciais participantes*",
                      MediaQuery.of(context).size.height * 0.018,
                      FontWeight.normal,
                      0.0,
                      Colors.black,
                      Colors.transparent),
                ],
              ),
              Layout().botaoret("Conheça os Mantenedores", Mantendores(), context),
              Hero(tag: 'card', child: Layout().cardfinal(context)),
              Layout().botaotodo("images/pintampinha.png", "Pontos de Coleta",PontosdeColeta(), context),
            ],
          )),
          statusVisualizacao || allStories.isEmpty
              ? Container()
              : Positioned(
                  bottom: 50,
                  right: 0,
                  child: InkWell(
                      onTap: () => _booleanSetMarcarComoVisto(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20), // Image border
                        child: SizedBox.fromSize(
                          size: Size.fromRadius(48), // Image radius
                          child: Image.asset('images/gifLogo.gif',
                              fit: BoxFit.cover),
                        ),
                      )),
                )
        ],
      ),
    );
  }

  _booleanSetMarcarComoVisto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KeysSharedPrefs.VISUALIZACAO, true);
    bool? valor = prefs.getBool(KeysSharedPrefs.VISUALIZACAO);
    setState(() {
      statusVisualizacao = valor!;
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Stories(
                stories: allStories.length < 5
                    ? allStories
                    : allStories.sublist(0, 5))));
  }

  Widget opcoesdrawer(context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Observer(builder: (_) {
          return ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Layout().menuheader(userLoginController!, context),
              (userLoginController!.isLoggedIn ||userLoginController!.loggedInAs ==UserLoggedAs.LOGGED_AS_ADMIN)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('Administração'),
                    ): Container(),
              (userLoginController!.isLoggedIn ||userLoginController!.loggedInAs ==UserLoggedAs.LOGGED_AS_ADMIN)
                  ? itemdrawer('Pesagem', 'images/help.png', Pesagem(), context)
                  : Container(),
              (userLoginController!.isLoggedIn ||userLoginController!.loggedInAs ==UserLoggedAs.LOGGED_AS_ADMIN)
                  ? itemdrawer('Incluir Notificação', 'images/notification.png', NotificacoesAdd(), context)
                  : Container(),
              (userLoginController!.isLoggedIn ||userLoginController!.loggedInAs ==UserLoggedAs.LOGGED_AS_ADMIN)
                  ? itemdrawerIcon('Adicionar história',Icons.add_a_photo_rounded,AdicionarStory(allStories),context)
                  : Container(),
              (userLoginController!.isLoggedIn ||userLoginController!.loggedInAs ==UserLoggedAs.LOGGED_AS_ADMIN)
                  ? Divider()
                  : Container(),
              itemdrawer('Conheça os Mantenedores', 'images/kindness.png',Mantendores(), context),
              itemdrawer('Entidades Assistenciais', 'images/help.png',EntidadesAssistenciais(), context),
              itemdrawer('Números', 'images/mapa.png', NumerosEstado(), context),
              itemdrawer('Notificações', 'images/notification.png',Notificacoes(), context),
              //  itemdrawer('Responda o Quiz', 'images/quiz.png', Quiz(), context),
              itemdrawer('Saiba Mais', 'images/question.png', SaibaMais(), context),
            ],
          );
        }),
        FutureBuilder(
          future: storiesFuturos,
          builder: (context, storiesSnapshot) {
            switch (storiesSnapshot.connectionState) {
              case ConnectionState.waiting:
                return Container();
              case ConnectionState.none:
                return Container();
              case ConnectionState.active:
                return CircularProgressIndicator();
              case ConnectionState.done:
                List<Story> stories = storiesSnapshot.data as List<Story>;

                if (storiesSnapshot.hasData &&
                    stories.isNotEmpty) {
                  return itemdrawerIcon(
                      'Histórias',
                      Icons.switch_account_outlined,
                      Stories(
                          stories: stories!.length < 5
                              ? stories
                              : stories.sublist(0, 5)),
                      context);
                }
              case ConnectionState.none:
                // TODO: Handle this case.
            }
            return Container();
          },
        ),
        Divider(),
      ],
    );
  }

  Widget itemdrawer(text, image, destino, context) {
    return Card(
      elevation: 1.0,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destino));
        },
        child: ListTile(
          title: Text(text),
          leading: Image.asset(
            image,
            width: 25.0,
            height: 25.0,
          ),
        ),
      ),
    );
  }

  Widget itemdrawerIcon(text, IconData icone, destino, context) {
    return Card(
      elevation: 1.0,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destino));
        },
        child: ListTile(
            title: Text(text),
            leading: Icon(
              icone,
              color: Colors.orange,
            )),
      ),
    );
  }

  Future<void> onTabTapped(int index) async {
    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NumerosEstado()));
    }
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Notificacoes()));
    }
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SaibaMais()));
    }
  }
}
