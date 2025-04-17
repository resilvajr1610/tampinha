import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';

import 'layout.dart';
import 'mantenedores.dart';
import 'models/connectToDB.dart';

class NumerosEstadoDetalhe extends StatefulWidget {
  @override
  _NumerosEstadoDetalheState createState() => _NumerosEstadoDetalheState();
}

class _NumerosEstadoDetalheState extends State<NumerosEstadoDetalhe> {
  String estado = 'Brasil';
  List<String> estados = [];
  final formatCurrency = new NumberFormat.simpleCurrency(locale: 'pt_BR');
  final formatter = NumberFormat("###,###.### kg", "pt-br");
  final formattern = NumberFormat("###,###", "pt-br");
  Map<String, List<dynamic>> estadosinfo = Map();

  conectardb() async {
    SQL conn = SQL();

    await conn.connectToDB();

    estados.add("Brasil");

    var tampometrodb = await conn.getConn().query(
        'select SUM(ntampinhas), SUM(valor), SUM(peso), SUM(ptsColeta), SUM(nEntidades) from app_tampometro');
    for (var row in tampometrodb) {
      setState(() {
        estadosinfo["Brasil"] = [row[0], row[1], row[2], row[3], row[4]];
      });
    }

    var tampometroestadodb = await conn.getConn().query(
        'select  estado, ntampinhas, valor, peso, ptsColeta, nEntidades  from app_tampometro where ptsColeta != 0 order by estado');
    for (var row in tampometroestadodb) {
      if (row[0] != 'TT') {
        setState(() {
          estados.add(row[0]);
          estadosinfo[row[0]] = [row[1], row[2], row[3], row[4], row[5]];
        });
      }
    }

    await conn.closeConnection();
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
          "", Mantendores(), context),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 50.0, right: 50.0, top: 8.0, bottom: 8.0),
                  child: Layout().dropdownitem("Selecione o estado", estado,
                      mudarEstado, estados, context),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Layout().textosimples(
                    "Tampômetro",
                    MediaQuery.of(context).size.height * 0.018,
                    FontWeight.normal,
                    -0.2,
                    Colors.black,
                    Colors.transparent),
                (estadosinfo != null && estadosinfo.length > 0)
                    ? Column(
                        children: [
                          Layout().textosimples(
                              formattern.format(estadosinfo[estado]?[0]),
                              MediaQuery.of(context).size.height * 0.035,
                              FontWeight.bold,
                              0.0,
                              Colors.black,
                              Colors.transparent),
                          Layout().textosimples(
                              "tampinhas recicladas",
                              MediaQuery.of(context).size.height * 0.018,
                              FontWeight.bold,
                              0.0,
                              Colors.black,
                              Colors.transparent),
                        ],
                      )
                    : Container(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Layout().textosimples(
                    "Valor Arrecadado",
                    MediaQuery.of(context).size.height * 0.018,
                    FontWeight.normal,
                    -0.2,
                    Colors.black,
                    Colors.transparent),
                (estadosinfo != null && estadosinfo.length > 0)
                    ? Layout().textosimples(
                        formatCurrency.format(estadosinfo[estado]?[1]),
                        MediaQuery.of(context).size.height * 0.035,
                        FontWeight.bold,
                        0.0,
                        Colors.black,
                        Colors.transparent)
                    : Container(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Layout().textosimples(
                    "Entidades Assistenciais Participantes",
                    MediaQuery.of(context).size.height * 0.018,
                    FontWeight.normal,
                    -0.2,
                    Colors.black,
                    Colors.transparent),
                (estadosinfo != null && estadosinfo.length > 0)
                    ? Layout().textosimples(
                        formattern.format(estadosinfo[estado]?[4]),
                        MediaQuery.of(context).size.height * 0.035,
                        FontWeight.bold,
                        0.0,
                        Colors.black,
                        Colors.transparent)
                    : Container(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Layout().textosimples(
                    "Peso Total ",
                    MediaQuery.of(context).size.height * 0.018,
                    FontWeight.normal,
                    -0.2,
                    Colors.black,
                    Colors.transparent),
                (estadosinfo != null && estadosinfo.length > 0)
                    ? Layout().textosimples(
                        formatter.format(estadosinfo[estado]?[2]),
                        MediaQuery.of(context).size.height * 0.035,
                        FontWeight.bold,
                        0.0,
                        Colors.black,
                        Colors.transparent)
                    : Container(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Layout().textosimples(
                    "Pontos de Coleta",
                    MediaQuery.of(context).size.height * 0.018,
                    FontWeight.normal,
                    -0.2,
                    Colors.black,
                    Colors.transparent),
                (estadosinfo != null && estadosinfo.length > 0)
                    ? Layout().textosimples(
                        formattern.format(estadosinfo[estado]?[3]),
                        MediaQuery.of(context).size.height * 0.035,
                        FontWeight.bold,
                        0.0,
                        Colors.black,
                        Colors.transparent)
                    : Container(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                Hero(tag: 'card', child: Layout().cardfinal(context)),
              ],
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void mudarEstado(String text) {
    setState(() {
      estado = text;
    });
  }
}
