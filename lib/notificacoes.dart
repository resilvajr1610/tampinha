import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tampinha/mantenedores.dart';
import 'layout.dart';
import 'models/connectToDB.dart';

class Notificacoes extends StatefulWidget {
  @override
  _NotificacoesState createState() => _NotificacoesState();
}

class _NotificacoesState extends State<Notificacoes> {
  Map<int, List<dynamic>> notificacoes = Map();

  @override
  void initState() {
    super.initState();

    conectardb();
  }

  conectardb() async {

    SQL conn = SQL();

    await conn.connectToDB();

    var notificacoesdb = await conn.getConn().query(
        'select id, datahora, notif from app_notif where ativo = 1 order by datahora desc');
    for (var row in notificacoesdb) {
      setState(() {
        notificacoes[row[0]] = [row[1], row[2]];
      });
    }
    await conn.closeConnection();
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget cardnoti(item, id) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.amber[50],
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Layout().textosimples(getDataeHora(item[0]), 17.0,
                  FontWeight.w600, 0.0, Colors.black, Colors.transparent),
              SizedBox(
                height: 3.0,
              ),
              Layout().textonoti(item[1].toString(), 15.0, FontWeight.w400, 0.0,
                  Colors.black, Colors.transparent),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: Divider(color: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }

  String getDataeHora(data) {
    String formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(data);
    return formattedDate;
  }
}
