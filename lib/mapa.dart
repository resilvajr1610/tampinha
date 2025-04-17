import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class Mapa extends StatefulWidget {
  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  List<String> estados = [];

  conectardb() async {
    var settings = new ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    var conn = await MySqlConnection.connect(settings);
    var estadosdb = await conn
        .query('select  estado from app_tampometro where ptsColeta != 0');
    for (var row in estadosdb) {
      setState(() {
        estados.add(row[0]);
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
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.51,
      child: Stack(
        children: <Widget>[
          Center(child: Image.asset("images/mapag.png")),
          mapaestado('AC'),
          mapaestado('AL'),
          mapaestado('AP'),
          mapaestado('AM'),
          mapaestado('BA'),
          mapaestado('CE'),
          mapaestado('DF'),
          mapaestado('ES'),
          mapaestado('GO'),
          mapaestado('MA'),
          mapaestado('MT'),
          mapaestado('MS'),
          mapaestado('MG'),
          mapaestado('PA'),
          mapaestado('PB'),
          mapaestado('PR'),
          mapaestado('PE'),
          mapaestado('PI'),
          mapaestado('RJ'),
          mapaestado('RN'),
          mapaestado('RS'),
          mapaestado('RO'),
          mapaestado('RR'),
          mapaestado('SC'),
          mapaestado('SP'),
          mapaestado('SE'),
          mapaestado('TO'),
        ],
      ),
    );
  }

  Widget mapaestado(estado) {
    return (estados != null && estados.contains(estado))
        ? Center(child: Image.asset("images/map$estado.png"))
        : Container();
  }
}
