import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'controllers/mysql_conexao.dart';
import 'layout.dart';
import 'mantenedores.dart';

class SaibaMais extends StatefulWidget {
  @override
  _SaibaMaisState createState() => _SaibaMaisState();
}

class _SaibaMaisState extends State<SaibaMais> {

  @observable
  var sobre = ObservableList<mysql.ResultRow>();

  @action
  conectardb() async {
    var settings = new mysql.ConnectionSettings(
      host: MysqlConexao().url,
      port: MysqlConexao().porta,
      user: MysqlConexao().login,
      password: MysqlConexao().senha,
      db: MysqlConexao().db,
    );
    var conn = await mysql.MySqlConnection.connect(settings);

    var sobredb = await conn.query('select textoSobre from app_sobre');
    for (var row in sobredb) {
      setState(() {
        sobre.add(row);
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
          "Conheça os Mantenedores", Mantendores(), context),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: Hero(
                          tag: 'logo',
                          child: Layout().logoextendido(
                              "images/logo.png",
                              MediaQuery.of(context).size.height * 0.1,
                              0.4,
                              context)),
                    ),
                    Layout().textosimples(
                        "Saiba Mais",
                        MediaQuery.of(context).size.height * 0.03,
                        FontWeight.bold,
                        0.0,
                        Colors.blue[700],
                        Colors.transparent),
                  ],
                ),
                Layout().textosimples(
                    "Conheça o Tampinha Legal",
                    MediaQuery.of(context).size.height * 0.03,
                    FontWeight.bold,
                    0.0,
                    Colors.black,
                    Colors.transparent),
                (sobre != null)
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 15.0,
                                left: 25.0,
                                right: 25.0,
                                bottom: 12.0),
                            child: Layout().textosimples(
                                sobre.length==0?'':sobre[0].toString(),
                                16.0,
                                FontWeight.w400,
                                0.0,
                                Colors.black,
                                Colors.white70),
                          ),
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                      ),
                Hero(tag: 'card', child: Layout().cardfinal(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
