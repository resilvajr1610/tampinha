import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:tampinha/entidadesassistenciais.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

import 'controllers/mysql_conexao.dart';
import 'layout.dart';
import 'models/connectToDB.dart';

class Mantendores extends StatefulWidget {
  @override
  _MantendoresState createState() => _MantendoresState();
}

class _MantendoresState extends State<Mantendores> {
  Map<String, String> mantenedores = Map();
  List<String> mantenedoresimagem = [];

  conectardb() async {
    var settings = new mysql.ConnectionSettings(
      host: MysqlConexao().url,
      port: MysqlConexao().porta,
      user: MysqlConexao().login,
      password: MysqlConexao().senha,
      db: MysqlConexao().db,
    );
    var conn = await mysql.MySqlConnection.connect(settings);

    var mantenedoresdb = await conn.query('select logo, urlsite from app_mantenedores where ativo = 1 order by nome');
    for (var row in mantenedoresdb) {
      setState(() {
        mantenedoresimagem.add(row[0]);
        mantenedores[row[0]] = row[1];
      });
    }
    await conn.close();
  }

  @override
  void initState() {
    super.initState();
    conectardb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Layout().appbarcombotaosimples(
          "Entidades Assistenciais Participantes",
          EntidadesAssistenciais(),
          context),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: Hero(
                          tag: "logo",
                          child: Layout().logoextendido(
                              "images/logo.png",
                              MediaQuery.of(context).size.height * 0.1,
                              0.4,
                              context)),
                    ),
                    Expanded(
                      child: Layout().textosimples(
                          "Mantenedores",
                          MediaQuery.of(context).size.height * 0.025,
                          FontWeight.bold,
                          0.0,
                          Colors.blue[700],
                          Colors.transparent),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Card(
                              child: InkWell(
                            onTap: () async {
                              var url = mantenedores[mantenedoresimagem[index]];
                              if (await canLaunch(url!)) {
                                await launch(url);
                              } else {
                                throw 'Não foi possível acessar $url';
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://www.tampinhalegal.com.br/sistema" +
                                        mantenedoresimagem[index]
                                            .replaceAll("..", ''),
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                        baseColor: Colors.grey,
                                        highlightColor: Colors.yellow,
                                        child: Image.asset('images/logo.png')),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          )));
                    },
                    itemCount: mantenedoresimagem.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
