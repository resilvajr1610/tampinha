import 'package:flutter/material.dart';
import 'package:tampinha/mapa.dart';

import 'mantenedores.dart';
import 'numeroestadodetalhe.dart';

import 'layout.dart';

class NumerosEstado extends StatefulWidget {
  @override
  _NumerosEstadoState createState() => _NumerosEstadoState();
}

class _NumerosEstadoState extends State<NumerosEstado> {
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                Layout().textosimples(
                    "Números por Estado",
                    MediaQuery.of(context).size.height * 0.03,
                    FontWeight.w600,
                    0.0,
                    Colors.black,
                    Colors.transparent),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NumerosEstadoDetalhe()));
                      },
                      child: Mapa()),
                ),
                Hero(tag: 'card', child: Layout().cardfinal(context)),
              ],
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
