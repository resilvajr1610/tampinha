import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mysql1/mysql1.dart' as mysql;
import 'package:tampinha/mantenedores.dart';
import 'package:tampinha/notificacoesadd.dart';

import 'layout.dart';

class NotificacoesAdm extends StatefulWidget {
  @override
  _NotificacoesAdmState createState() => _NotificacoesAdmState();
}

class _NotificacoesAdmState extends State<NotificacoesAdm> {
  Map<int, List<dynamic>> notificacoes = Map();

  @override
  void initState() {
    super.initState();

    conectardb();
  }

  conectardb() async {
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    var conn = await mysql.MySqlConnection.connect(settings);

    var notificacoesdb = await conn.query(
        'select id, datahora, notif from app_notif where ativo = 1 order by datahora desc');
    for (var row in notificacoesdb) {
      setState(() {
        notificacoes[row[0]] = [row[1], row[2]];
      });
    }
    await conn.close();
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
                      image: AssetImage("images/fundo2.png"),
                      fit: BoxFit.cover)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 25.0, right: 25.0),
                          child: Hero(
                              tag: "logo",
                              child: Layout().logoextendido(
                                  "images/logo.png",
                                  MediaQuery.of(context).size.height * 0.1,
                                  0.4,
                                  context)),
                        ),
                        Layout().textosimples(
                            "Importante",
                            MediaQuery.of(context).size.height * 0.03,
                            FontWeight.bold,
                            0.0,
                            Colors.blue[700],
                            Colors.transparent),
                      ],
                    ),
                    Layout().textosimples(
                        "Notificações",
                        MediaQuery.of(context).size.height * 0.03,
                        FontWeight.bold,
                        0.0,
                        Colors.black,
                        Colors.transparent),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    (notificacoes != null)
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: ListView.builder(
                                itemCount: notificacoes.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  int key = notificacoes.keys.elementAt(index);
                                  return cardnoti(notificacoes[key], key);
                                }),
                          )
                        : Container(),
                    Hero(tag: 'card', child: Layout().cardfinal(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Layout().floatingactionbar(
            _floatingaction, Icons.edit, "Publicar", context));
  }

  void _floatingaction() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NotificacoesAdd()));
  }

  Widget cardnoti(item, id) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.amber[50],
        elevation: 3.0,
        child: InkWell(
          onLongPress: () {
            deletar(id, context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Layout().textosimples(getDataeHora(item[0]), 17.0,
                    FontWeight.w600, 0.0, Colors.black, Colors.transparent),
                SizedBox(
                  height: 3.0,
                ),
                Layout().textosimples(item[1].toString(), 15.0, FontWeight.w400,
                    0.0, Colors.black, Colors.transparent),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                  child: Divider(color: Colors.red),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? deletar(id, context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text("Deletar Publicação"),
            content: new Text("Deseja deletar esta publicação?"),
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
                  isDefaultAction: true,
                  child: Text(
                    "DELETAR",
                    style: TextStyle(color: Colors.amber),
                  ),
                  onPressed: () {
                    conectardbdeletar(id);

                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  conectardbdeletar(id) async {
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    var conn = await mysql.MySqlConnection.connect(settings);

    await conn.query('update app_notif set ativo=? where id=?', [0, id]);

    await conn.close();
  }

  String getDataeHora(data) {
    String formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(data);
    return formattedDate;
  }
}
