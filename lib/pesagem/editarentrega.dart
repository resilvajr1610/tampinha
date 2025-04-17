import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tampinha/design.dart';
import 'package:mysql1/mysql1.dart' as mysql;

import 'package:tampinha/layout.dart';
import 'package:tampinha/pesagem/novaentrega.dart';

class EditarEntrega extends StatefulWidget {
  final DocumentSnapshot pesagemDoc;

  const EditarEntrega({Key? key,required this.pesagemDoc}) : super(key: key);

  @override
  _EditarEntregaState createState() => _EditarEntregaState();
}

class _EditarEntregaState extends State<EditarEntrega> {
  List<PesagemObject> pesagemList = [];

  PesagemObject? pesagemParcial;
  final formatCurrency = new NumberFormat.simpleCurrency(locale: 'pt_BR');

  int? entregaID;
  Stream<QuerySnapshot>? firebasePesagemStream;
  mysql.MySqlConnection? sqlConnection;
  bool connectionInitialized = false;

  TextStyle pesagemInfoTextStyle = TextStyle(fontSize: 18);

  Future<bool> initConnection() async {
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    sqlConnection = await mysql.MySqlConnection.connect(settings);
    connectionInitialized = true;
    return true;
  }

  void convertPesagemMapsToObject() {
    pesagemList.clear();
    List<dynamic> pesagemListOfMaps = widget.pesagemDoc['pesagens'];
    pesagemListOfMaps.forEach((element) {
      PesagemObject pesagemAux = PesagemObject(
        peso: element['peso'].toDouble(),
        valor: element['valor'].toDouble(),
        corTampinha: element['tampinhacor'],
        nucleoID: widget.pesagemDoc['nucleoid'],
        nucleoNome: widget.pesagemDoc['nucleonome'],
        entidadeNome: widget.pesagemDoc['entidade'],
        data: DateFormat('dd/MM/yyyy').parse(widget.pesagemDoc['data']),
        entregaID: widget.pesagemDoc['entregaid'],
        recicladorNome: widget.pesagemDoc['recicladornome'],
        recicladorID: widget.pesagemDoc['recicladorid'],
        entidadeID: 0
      );
      pesagemList.add(pesagemAux);
    });
  }

  @override
  void initState() {
    convertPesagemMapsToObject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Hero(
                        tag: 'logo',
                        child: Layout().logoextendido("images/logo.png",
                            MediaQuery.of(context).size.height * 0.1, 0.4, context)),
                  ),
                  widget.pesagemDoc['status'] == StatusPesagem.PENDENTE
                      ? Expanded(
                          child: Layout().textosimples(
                              "Entrega Pendente",
                              MediaQuery.of(context).size.height * 0.03,
                              FontWeight.bold,
                              0.0,
                              Colors.blue[700],
                              Colors.transparent),
                        )
                      : Expanded(
                          child: Layout().textosimples(
                              "Entrega Concluida",
                              MediaQuery.of(context).size.height * 0.03,
                              FontWeight.bold,
                              0.0,
                              Colors.blue[700],
                              Colors.transparent),
                        ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(widget.pesagemDoc['nucleonome'],
                style: pesagemInfoTextStyle, textAlign: TextAlign.center),
            SizedBox(
              height: 8,
            ),
            Text(
              widget.pesagemDoc['entidade'],
              style: pesagemInfoTextStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8,
            ),
            Text(widget.pesagemDoc['data'],
                style: pesagemInfoTextStyle, textAlign: TextAlign.center),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ListView.builder(
                        itemCount: pesagemList.length,
                        itemBuilder: (BuildContext context, int index) {
                          CorEContraCor corEcontraCor =
                              TampinhaCores().colorFromString(pesagemList[index].corTampinha);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black45),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                child: Row(
                                  children: [
                                    Container(
                                        width: 120,
                                        color: corEcontraCor.cor,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "${pesagemList[index].corTampinha}",
                                              style: TextStyle(color: corEcontraCor.contraCor),
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                      child: Container(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Peso: ${pesagemList[index].peso} kg",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Center(
                        child: Text(
                      "Peso Total: ${widget.pesagemDoc['pesototal']} kg",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(60, 60, 60, 1)),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Center(
                        child: Text(
                      "Valor Total: ${formatCurrency.format(widget.pesagemDoc['valortotal'])}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(60, 60, 60, 1)),
                    )),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
