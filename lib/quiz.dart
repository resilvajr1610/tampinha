
import 'package:flutter/material.dart';
import 'package:tampinha/mantenedores.dart';

import 'layout.dart';

class Quiz extends StatefulWidget {
  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
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
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Layout().textosimples(
                      "Em breve, o quiz do\nTampinha Legal 👍\npara você.",
                      MediaQuery.of(context).size.height * 0.03,
                      FontWeight.w600,
                      0.0,
                      Colors.black,
                      Colors.transparent),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Hero(tag: 'card', child: Layout().cardfinal(context)),
              ],
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
