import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'controllers/pontosdecoleta_controller.dart';
import 'layout.dart';

class PontosdeColeta extends StatefulWidget {
  @override
  _PontosdeColetaState createState() => _PontosdeColetaState();
}

class _PontosdeColetaState extends State<PontosdeColeta> {
  PontosdeColetaController controller = PontosdeColetaController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          ElevatedButton(
            onPressed: () async {
              controller.getUserLocation();
            },
            child: Text(
              'Usar GPS',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              controller.dialog(context);
            },
            child: Text(
              'Pesquisar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 10.0, top: 15.0),
                      child: Hero(
                        tag: 'logo',
                        child: Layout().logoextendido(
                            "images/logo.png",
                            MediaQuery.of(context).size.height * 0.1,
                            0.4,
                            context),
                      ),
                    ),
                    Expanded(
                      child: Layout().textosimples(
                          "Pontos de Coleta",
                          MediaQuery.of(context).size.height * 0.03,
                          FontWeight.bold,
                          0.0,
                          Colors.blue[700],
                          Colors.transparent),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    child: Observer(
                      builder: (_) {
                        return GoogleMap(
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          markers: Set.from(controller.markers),
                          myLocationButtonEnabled: true,
                          initialCameraPosition: controller.position,
                          onMapCreated: (GoogleMapController controller) {
                            this.controller.controllerMap.complete(controller);
                          },
                        );
                      },
                    ),
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
