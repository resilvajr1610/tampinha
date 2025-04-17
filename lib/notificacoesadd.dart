import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;

import 'layout.dart';

class NotificacoesAdd extends StatefulWidget {
  @override
  _NotificacoesAddState createState() => _NotificacoesAddState();
}

class _NotificacoesAddState extends State<NotificacoesAdd> {
  TextEditingController texto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbarcomumbotao(parasalvar, "Incluir Notificação", "Salvar", context),
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
                      Expanded(
                        child: Layout().textosimples(
                            "Incluir",
                            MediaQuery.of(context).size.height * 0.03,
                            FontWeight.bold,
                            0.0,
                            Colors.blue[700],
                            Colors.transparent),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Layout().caixadetexto(3, 50, TextInputType.multiline, texto,
                      "Escreva a Notificação", TextCapitalization.sentences),
                  Hero(tag: 'card', child: Layout().cardfinal(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void parasalvar(context) {
    if (texto.text.isNotEmpty) {
      conectardb();
      enviarnotificacao(texto.text);
    } else {
      Layout()
          .dialog1botao(context, 'Texto', "Escreva o texto da notificação.");
    }
  }

  enviarnotificacao(mensagem) {
    Map<String, Object> noti = Map();
    noti['mensagem'] = mensagem;
    FirebaseFunctions.instance
        .httpsCallable("enviarnotificacao")
        .call(noti);
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

    DateTime now = DateTime.now();
    var data =
        new DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);

    await conn.query(
        'insert into app_notif (notif, datahora, ativo) values (?, ?, ?)',
        [texto.text, data, 1]);

    await conn.close();
    setState(() {
      texto.text = "";
    });
    Layout().dialog1botao(context, 'Enviada', "Notificação enviada.");
  }
}
