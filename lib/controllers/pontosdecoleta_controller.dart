import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:location/location.dart' as loc;
import 'package:mobx/mobx.dart';
import 'package:mysql1/mysql1.dart' as mysql;

import 'mysql_conexao.dart';
part 'pontosdecoleta_controller.g.dart';

class PontosdeColetaController = _PontosdeColetaControllerBase with _$PontosdeColetaController;

abstract class _PontosdeColetaControllerBase with Store {
  //OBSERVABLES
  @observable
  places.Location location = places.Location(lat: 0.0, lng: 0.0);
  @observable
  CameraPosition position = CameraPosition(
    target: LatLng(-30.0346, -51.2177),
    zoom: 14.4746,
  );
  @observable
  var markers = ObservableList<Marker>();
  @observable
  var entidadesRows = ObservableList<mysql.ResultRow>();
  @observable
  Map<String, int> entidades = Map();
  @observable
  String entidadeSelecionada = '';
  @observable
  var suggestions = ObservableList<String>();

  //Variáveis comuns (NÃO OBSERVABLES)
  Completer<GoogleMapController> controllerMap = Completer();
  late BitmapDescriptor pintampinhaIcon;
  static const kGoogleApiKey = "AIzaSyCihP6hWj36uHTn8aYqxYMUQ3A_y9u33_c";
  places.GoogleMapsPlaces _places = places.GoogleMapsPlaces(apiKey: kGoogleApiKey);
  var settings;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  TextEditingController controllerText = TextEditingController();

  _PontosdeColetaControllerBase(){
    conectardb();
    getUserLocation();
    getEntidades();
  }

  @action
  getEntidades() async {
    print('ENTROUU');
    var conn = await mysql.MySqlConnection.connect(settings);
    var results = await conn.query(
        'select EntEnder, EntLat, EntLng, EntNum, EntCidade, EntNomeFantasia, EntID from entidades where EntDel = 0 and EntPesoTotal != 0 order by EntNomeFantasia ASC');
    for (var row in results) {
      entidades['${row.fields['EntNomeFantasia']}'] =
          int.parse(row.fields['EntID'].toString());
      entidadesRows.add(row);
    }
    entidadesRows.forEach((row) async {
      if (row.fields['EntEnder'] != null &&
          row.fields['EntNum'] != null &&
          row.fields['EntCidade'] != null) {
        if (row.fields['EntEnder'].toString().isNotEmpty &&
            row.fields['EntNum'].toString().isNotEmpty &&
            row.fields['EntCidade'].toString().isNotEmpty) {
          if (row.fields['EntLat'] == null && row.fields['EntLng'] == null) {
            // print(row.fields['EntEnder']);
            //getCoordenadas('${row.fields['EntEnder']}',
               // '${row.fields['EntNum']}', '${row.fields['EntCidade']}');
          } else {
            markers.add(
              Marker(
                  markerId: MarkerId(
                      '${row.fields['EntEnder']} ${row.fields['EntNum']} ${row.fields['EntCidade']}'),
                  infoWindow: InfoWindow(
                      title:
                          '${row.fields['EntEnder']} ${row.fields['EntNum']} ${row.fields['EntCidade']}',
                      snippet:
                          '${row.fields['EntEnder']} ${row.fields['EntNum']} ${row.fields['EntCidade']}'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                  position: LatLng(
                      double.parse(row.fields['EntLat'].toString()),
                      double.parse(row.fields['EntLng'].toString()))),
            );
          }
        }
      }
    });

    //Preencher dropdown
    results = await conn.query(
        'select distinct EntNomeFantasia from entidades where EntDel = 0 and EntPesoTotal != 0 and EntLat is not null and EntLng is not null order by EntNomeFantasia ASC');
    suggestions.clear();
    suggestions.add('Todas');
    for (var row in results) {
      suggestions.add(row.fields['EntNomeFantasia'].toString());
    }
    entidadeSelecionada = 'Todas';

    await conn.close();
  }

  @action
  conectardb() async {
     settings = new mysql.ConnectionSettings(
       host: MysqlConexao().url,
       port: MysqlConexao().porta,
       user: MysqlConexao().login,
       password: MysqlConexao().senha,
       db: MysqlConexao().db,
    );
    await pintampinha();
    var conn = await mysql.MySqlConnection.connect(settings);

    var results = await conn.query(
        'select PtNome, PtEnder, PtNum, PtComplem, PtLat, PtLng from pontosdecoleta where PtDel != 1');

    for (var row in results) {
    markers.add(
      Marker(
          markerId: MarkerId(row[0]),
          infoWindow: InfoWindow(
              title: row[0],
              snippet: "${row[1]}, ${row[2].toString()} - ${row[3]}"),
          icon: pintampinhaIcon,
          position: LatLng(row[4], row[5])),
    );
    }

    await conn.close();
  }

  @action
  getUserLocation() async {
    loc.Location().getLocation().then((data) async {
      location = places.Location(lat: data.latitude!, lng: data.longitude!,);
      position = CameraPosition(
        target: LatLng(data.latitude!, data.longitude!),
        zoom: 14.4746,
      );
    });
    final GoogleMapController controller = await controllerMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
    getEntidades();
  }

  @action
  placesAutoComplete(BuildContext context, places.Prediction prediction) async {
    Navigator.pop(context);
    print(prediction != null);
    places.PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(prediction.placeId!);
    print(detail != null);
    print(detail.errorMessage);
    print(detail.result);
    print(prediction.placeId);
    print(prediction.description.toString());

    double lat = detail.result.geometry!.location.lat;
    double lng = detail.result.geometry!.location.lng;
    print(lat);
    print(lng);

    markers.add(
      Marker(
          markerId: MarkerId(prediction.description.toString()),
          infoWindow: InfoWindow(
              title: prediction.description.toString(),
              snippet: prediction.description.toString()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: LatLng(lat, lng)),
    );

    position = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.4746,
    );
    final GoogleMapController controller = await controllerMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  @action
  getCoordenadas(String rua, String numero, String cidade) async {
    try {
      List<Location> placemark = await locationFromAddress('$rua $numero $cidade');
      var conn = await mysql.MySqlConnection.connect(settings);
      print('CHEGOU');
      var results = await conn.query(
          "update entidades set EntLat = '${placemark[0].latitude.toString()}', EntLng = '${placemark[0].longitude.toString()}' where EntEnder = '$rua' and EntNum='$num' and EntCidade='$cidade'");
      print(results.affectedRows);
      await conn.close();
      markers.add(
        Marker(
            markerId: MarkerId('$rua $numero $cidade'),
            infoWindow: InfoWindow(    title: '$rua $numero $cidade', snippet: '$rua $numero $cidade'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            position: LatLng(placemark[0].latitude,placemark[0].longitude)),
      );
    } catch (e) {
      print('ERROOO');
      print(e);
    }
  }

  @action
  changeDropdown(value) {
    entidadeSelecionada = value;
  }

  // @action
  // filtroEntidade(String text) {
  //   entidadeSelecionada = text;
  //   controllerText.text = entidadeSelecionada;
  // }


  //Filtro dropdown de filtro de pontos de coleta por Entidades (So aparece aquelas Entidades em que possuem lat e lng predefinidas no banco de dados)
  @action
  aplicarFiltros() async {
    if(entidadeSelecionada != 'Todas'){
    var conn = await mysql.MySqlConnection.connect(settings);
    var results = await conn.query(
        "select PtNome, PtEnder, PtNum, PtComplem, PtLat, PtLng from pontosdecoleta where PtDel != 1 and PtIDEnt = '${entidades[entidadeSelecionada]}'");
    markers.clear();
    print(entidades[entidadeSelecionada]);
    print(markers.length);
    //adicionar pontos de coleta da entidade selecionada
    for (var row in results) {
      markers.add(
        Marker(
            markerId: MarkerId(row[0]),
            infoWindow: InfoWindow(
                title: row[0],
                snippet: "${row[1]}, ${row[2].toString()} - ${row[3]}"),
            icon: pintampinhaIcon,
            position: LatLng(row[4], row[5])),
      );
    }
     print(markers.length);
    results = await conn.query(
        "select EntEnder, EntNum, EntCidade, EntLat, EntLng from entidades where EntDel = 0 and EntPesoTotal != 0 and EntID = '${entidades[entidadeSelecionada]}'");
    //adicionar entidade em verde no mapa
    String rua = '', numero = '', cidade = '';
    rua = '${results.first.fields['EntEnder'].toString()}';
    numero = '${results.first.fields['EntNum'].toString()}';
    cidade = '${results.first.fields['EntCidade'].toString()}';

    markers.add(Marker(
      markerId: MarkerId('$rua $numero $cidade'),
      infoWindow: InfoWindow(
          title: '$rua $numero $cidade', snippet: '$rua $numero $cidade'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: LatLng(double.parse(results.first.fields['EntLat'].toString()),
          double.parse(results.first.fields['EntLng'].toString())),
    ));

    position = CameraPosition(
      target: LatLng(double.parse(results.first.fields['EntLat'].toString()),
          double.parse(results.first.fields['EntLng'].toString())),
      zoom: 14.4746,
    );

    final GoogleMapController controller = await controllerMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
    }else{
      print('Limpando');
      markers.clear();
      getUserLocation();
      Future.delayed(Duration(seconds: 2)).then((value) => getUserLocation());
    
      //Adicionar os pontos de coleto denovo
    var conn = await mysql.MySqlConnection.connect(settings);
    print(entidades[entidadeSelecionada]);
    var results = await conn.query(
        "select PtNome, PtEnder, PtNum, PtComplem, PtLat, PtLng from pontosdecoleta where PtDel != 1");
    print(results.length);
    markers.clear();
    for (var row in results) {
      markers.add(
        Marker(
            markerId: MarkerId(row[0]),
            infoWindow: InfoWindow(
                title: row[0],
                snippet: "${row[1]}, ${row[2].toString()} - ${row[3]}"),
            icon: pintampinhaIcon,
            position: LatLng(row[4], row[5])),
      );
    }
    }
  }

//FUNCÇÕES NÃO ACTION
  dialog(context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text("Pesquise por Entidades ou Endereços"),
            content: Column(children: [
              Column(
                children: [
                  Card(
                    elevation: 0.0,
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 35,
                      child: InkWell(
                        onTap: () {
                          PlacesAutocomplete.show(
                            context: context,
                            apiKey: kGoogleApiKey,
                            mode: Mode.fullscreen,
                            location: location == null ? null : location,
                            radius: 50,
                            language: 'pt',
                          ).then((prediction) async {
                            await placesAutoComplete(context, prediction!);
                          });
                        },
                        child: Text(
                          'Clique aqui para digitar o endereço',
                          style: TextStyle(
                              letterSpacing: 1.5,
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    elevation: 0.0,
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 35.0,
                      child: Observer(builder: (_) {
                        return DropdownButton(
                          isExpanded: true,
                          value: entidadeSelecionada,
                          items: suggestions.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('$value'),
                              ),
                            );
                          }).toList(),
                          onChanged: changeDropdown,
                        );
                        // return SimpleAutoCompleteTextField(
                        //   key: key,
                        //   decoration: new InputDecoration(),
                        //   controller:
                        //       TextEditingController(),
                        //   suggestions: suggestions,
                        //   textChanged: (text) => print(text),
                        //   clearOnSubmit: true,
                        //   textSubmitted: filtroEntidade
                        // );
                      }),
                    ),
                  ),
                ],
              ),
            ]),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Aplicar",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  aplicarFiltros();
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  pintampinha() async {
    pintampinhaIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 5.5), 'images/pintampinha.png');
  }
}
