import 'dart:async';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart' as mysql;

import '../design.dart';
import '../layout.dart';
import 'componentes/edit_or_delete_dialog.dart';
import 'componentes/pesagemdialog.dart';


class NovaEntrega extends StatefulWidget {
  @override
  _NovaEntregaState createState() => _NovaEntregaState();
}

class _NovaEntregaState extends State<NovaEntrega> {
  String? nucleo;
  bool nucleoFoiSelecionado = false;
  Map<String, dynamic> nucleosMap = Map<String, dynamic>();
  Future<List<String>>? nucleosFuture;
  int? nucleoSelecionadoID;
  final formatCurrency = new NumberFormat.simpleCurrency(locale: 'pt_BR');
  String? dataEntrega;
  bool dataEntregaFoiSelecionada = false;
  Future<List<String>>? dataEntregaFuture;
  List<String> dataEntregaList = [];

  bool entidadeFoiSelecionada = false;
  Future<List<String>>? entidadeFuture;
  Map<String, dynamic> entidadesMap = Map<String, dynamic>();
  String? entidadeSelecionadaIDNome;
  int? entidadeSelecionadaID;
  String? entidadeSelecionadaNome;
  int? entregaID;
  String? recicladorSelecionado;
  int? recicladorSelecionadoID;
  bool recicladorFoiSelecionado = false;
  Future<List<String>>? recicladoresFuture;
  Map<String, dynamic> recicladoresMap = Map<String, dynamic>();
  mysql.Results? valoresQuery;
  mysql.ResultRow? recicladorSelecionadoValoresRow;

  Map<String, dynamic> valorTampinhaMap = Map<String, dynamic>();

  List<String> entidadesList = [];

  List<PesagemObject> pesagemList = [];
  List<Map<String, dynamic>> pesagemListOfMaps = [];

  PesagemObject? pesagemParcial;

  Stream<QuerySnapshot>? firebasePesagemStream;

  double? pesoTotal;

  Future<void> mudarNucleo(String text) async {
    setState(() {
      nucleo = text;
      nucleoSelecionadoID = nucleosMap[nucleo];
      dataEntregaFuture = pesquisarDatasEntrega();
      entregaID = null;
      dataEntregaFoiSelecionada = false;
      recicladorFoiSelecionado = false;
      entidadeFoiSelecionada = false;
      dataEntrega = null;
      recicladorSelecionado = null;
      recicladorSelecionadoID = null;
      nucleoFoiSelecionado = true;
    });
  }

  void mudarDataEntrega(String text) {
    print('data');
    setState(() {
      dataEntrega = text;
      dataEntregaFoiSelecionada = true;
      entidadeSelecionadaIDNome = null;
      entregaID = null;
      entidadeFoiSelecionada = false;
      entidadeFuture = pesquisarEntidadesEReciclador();
    });
  }

  void mudarEntidade(String text) {
    setState(() {
      entidadeSelecionadaIDNome = text;
      entidadeSelecionadaNome = entidadeSelecionadaIDNome!.split('-:-').last.trimLeft();
      entidadeSelecionadaID = entidadesMap[entidadeSelecionadaNome];
      entidadeFoiSelecionada = true;
      firebasePesagemStream = firebasePesagemQuery();

    });
  }

  Future<List<String>> pesquisarNucleos() async {
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    var conn = await mysql.MySqlConnection.connect(settings);

    mysql.Results nucleosQuery = await conn.query("select * from nucleos ORDER BY NucleoNome");

    nucleosMap.clear();
    for (var row in nucleosQuery) {
      nucleosMap[row['NucleoNome']] = row['NucleoID'];
    }
    conn.close();
    return nucleosMap.keys.toList();
  }


  Future<List<String>> pesquisarDatasEntrega() async {
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    var conn = await mysql.MySqlConnection.connect(settings);

    DateTime today = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);

    mysql.Results dataEntregaQuery = await conn.query(
      "select distinct CAST(Horario AS date) from agenda_horarios WHERE NucleoID = '$nucleoSelecionadoID' AND Horario > '$formattedDate'");


    dataEntregaList.clear();
    for (var row in dataEntregaQuery) {
      DateTime date = row[0];
      String formattedDate = DateFormat('dd/MM/yyyy').format(date);
      dataEntregaList.add(formattedDate);
    }
    conn.close();

    return dataEntregaList;
  }

  Future<void> pesquisarReciclador(conn) async {
    print('chamou3');
    DateTime dateTime = DateFormat('dd/MM/yyyy').parse(dataEntrega!);

    mysql.Results recicladorEntregaQuery = await conn.query(
        "select EntrNomeReciclador, EntrIDReciclador, EntrID from entregas WHERE CAST(EntrData AS date) = '$dateTime' AND EntrIDNucleo = '$nucleoSelecionadoID'");

    recicladorSelecionado = recicladorEntregaQuery.first['EntrNomeReciclador'];
    recicladorSelecionadoID = recicladorEntregaQuery.first['EntrIDReciclador'];
    print(recicladorEntregaQuery.first['EntrIDReciclador']);
    entregaID = recicladorEntregaQuery.first['EntrID'];
    print(entregaID);
    print(recicladorSelecionadoID);

    valoresQuery =
    await conn.query("select * from valores_entregas WHERE ValEntr_IDEntr='$entregaID'");

    atribuirValoresAsTampinhas(valoresQuery!.first);

    return;
  }

  Future<List<String>> pesquisarEntidades(conn) async {
    print('chamou4');

    DateTime dateTime = DateFormat('dd/MM/yyyy').parse(dataEntrega!);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    mysql.Results EntidadesFromAgendaQuery = await conn.query(
        "select distinct EntidadeID from agenda_horarios WHERE NucleoID = '$nucleoSelecionadoID' AND CAST(Horario AS date) = '$formattedDate'");
print(EntidadesFromAgendaQuery.toString());
    List<int> entidadeIDList = [];
    for (var row in EntidadesFromAgendaQuery) {
      entidadeIDList.add(row[0]);
    }

    String EntidadeIDListFormatted =
    entidadeIDList.toString().replaceFirst('[', '(').replaceFirst(']', ')');

    mysql.Results EntidadesNomesQuery = await conn.query(
        "select EntNomeFantasia, EntID from entidades WHERE EntID IN $EntidadeIDListFormatted ORDER BY EntNomeFantasia");
    print(EntidadesNomesQuery.toString());
    entidadesMap.clear();
    entidadesList.clear();
    for (var row in EntidadesNomesQuery) {
      entidadesMap[row[0]] = row[1];
      entidadesList.add(row[1].toString() + ' -:- ' + row[0].toString());
    }

    return entidadesList;
  }

  Future<List<String>> pesquisarEntidadesEReciclador() async {
    print('chamou2');
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    var conn = await mysql.MySqlConnection.connect(settings);
    entidadesList = await pesquisarEntidades(conn);
    await pesquisarReciclador(conn);

    conn.close();
    return entidadesList;
  }

  double cacularTotal() {
    // atribuirValoresAsTampinhas(recicladorValoresRow.first);
    return calcularValorDaPesagem();
  }

  double calcularValorDaPesagem() {
    double total = 0;
    for (int i = 0; i < pesagemList.length; i++) {
      total += valorTampinhaMap[pesagemList[i].corTampinha] * pesagemList[i].peso;
    }
    return total;
  }

  void atribuirValoresAsTampinhas(mysql.ResultRow row) {
    //ValEntr_Full

    if (row['ValEntr_Azul'] == 0 || row['ValEntr_Azul'] == null) {
      valorTampinhaMap[TampinhaCores.COR_AZUL] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_AZUL] = row['ValEntr_Azul'];
    }
    if (row['ValEntr_Amarelo'] == 0 || row['ValEntr_Amarelo'] == null) {
      valorTampinhaMap[TampinhaCores.COR_AMARELO] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_AMARELO] = row['ValEntr_Amarelo'];
    }
    if (row['ValEntr_Branco'] == 0 || row['ValEntr_Branco'] == null) {
      valorTampinhaMap[TampinhaCores.COR_BRANCO] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_BRANCO] = row['ValEntr_Branco'];
    }
    if (row['ValEntr_Cinza'] == 0 || row['ValEntr_Cinza'] == null) {
      valorTampinhaMap[TampinhaCores.COR_CINZA] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_CINZA] = row['ValEntr_Cinza'];
    }
    if (row['ValEntr_Color'] == 0 || row['ValEntr_Color'] == null) {
      valorTampinhaMap[TampinhaCores.COR_COLOR] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_COLOR] = row['ValEntr_Color'];
    }
    if (row['ValEntr_Cristal'] == 0 || row['ValEntr_Cristal'] == null) {
      valorTampinhaMap[TampinhaCores.COR_CRISTAL] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_CRISTAL] = row['ValEntr_Cristal'];
    }
    if (row['ValEntr_Dourado'] == 0 || row['ValEntr_Dourado'] == null) {
      valorTampinhaMap[TampinhaCores.COR_DOURADO] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_DOURADO] = row['ValEntr_Dourado'];
    }
    if (row['ValEntr_Laranja'] == 0 || row['ValEntr_Laranja'] == null) {
      valorTampinhaMap[TampinhaCores.COR_LARANJA] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_LARANJA] = row['ValEntr_Laranja'];
    }
    if (row['ValEntr_Marrom'] == 0 || row['ValEntr_Marrom'] == null) {
      valorTampinhaMap[TampinhaCores.COR_MARROM] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_MARROM] = row['ValEntr_Marrom'];
    }
    if (row['ValEntr_Preto'] == 0 || row['ValEntr_Preto'] == null) {
      valorTampinhaMap[TampinhaCores.COR_PRETO] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_PRETO] = row['ValEntr_Preto'];
    }
    if (row['ValEntr_Rosa'] == 0 || row['ValEntr_Rosa'] == null) {
      valorTampinhaMap[TampinhaCores.COR_ROSA] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_ROSA] = row['ValEntr_Rosa'];
    }
    if (row['ValEntr_Roxo'] == 0 || row['ValEntr_Roxo'] == null) {
      valorTampinhaMap[TampinhaCores.COR_ROXO] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_ROXO] = row['ValEntr_Roxo'];
    }
    if (row['ValEntr_Verde'] == 0 || row['ValEntr_Verde'] == null) {
      valorTampinhaMap[TampinhaCores.COR_VERDE] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_VERDE] = row['ValEntr_Verde'];
    }
    if (row['ValEntr_Vermelho'] == 0 || row['ValEntr_Vermelho'] == null) {
      valorTampinhaMap[TampinhaCores.COR_VERMELHO] = row['ValEntr_Full'];
    } else {
      valorTampinhaMap[TampinhaCores.COR_VERMELHO] = row['ValEntr_Vermelho'];
    }
    valorTampinhaMap[TampinhaCores.COR_FULL] = row['ValEntr_Full'];
  }

  Stream<QuerySnapshot> firebasePesagemQuery() {
    return FirebaseFirestore.instance
        .collection('Pesagem')
        .where('nucleoid', isEqualTo: nucleoSelecionadoID)
        .where('nucleonome', isEqualTo: nucleo)
        .where('entidade', isEqualTo: entidadeSelecionadaNome)
        .where('data', isEqualTo: dataEntrega)
        .snapshots();
  }

  void convertPesagemMapsToObject() {
    pesagemList.clear();
    pesagemListOfMaps.forEach((element) {
      PesagemObject pesagemAux = PesagemObject(
        peso: element['peso'].toDouble(),
        corTampinha: element['tampinhacor'],
        nucleoID: nucleoSelecionadoID!,
        entidadeID: entidadeSelecionadaID!,
        nucleoNome: nucleo!,
        entidadeNome: entidadeSelecionadaNome!,
        data: DateFormat('dd/MM/yyyy').parse(dataEntrega!),
        entregaID: entregaID!,
        recicladorID: recicladorSelecionadoID!,
        recicladorNome: recicladorSelecionado!,
        valor: 0.0
      );
      pesagemList.add(pesagemAux);
    });
  }

  @override
  void initState() {
    nucleosFuture = pesquisarNucleos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Hero(
                        tag: 'logo',
                        child: Layout().logoextendido("images/logo.png",
                            MediaQuery.of(context).size.height * 0.1, 0.4, context)),
                  ),
                  Expanded(
                    child: Layout().textosimples(
                        "Nova Entrega",
                        MediaQuery.of(context).size.height * 0.03,
                        FontWeight.bold,
                        0.0,
                        Colors.blue[700],
                        Colors.transparent),
                  ),
                ],
              ),
              FutureBuilder<List<String>>(
                  future: nucleosFuture,
                  builder: (context, nucleosSnapshot) {
                    switch (nucleosSnapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return Layout().dropdownWithoutImage(
                            "Carregando Núcleos...", nucleo, null, [], context);
                      case ConnectionState.done:
                        if (nucleosSnapshot.hasData) {
                          return Layout().dropdownWithoutImage("Selecione o Núcleo", nucleo,
                              mudarNucleo, nucleosSnapshot.data, context);
                        }
                        return Center(
                            child: Text(
                                "Não foi possivel recuperar os nucleos.\nVerifique sua conexão e tente novamente"));
                      case ConnectionState.none:
                        return Center(
                            child: Text(
                                "Não foi possivel recuperar os nucleos.\nVerifique sua conexão e tente novamente"));
                    }
                    return Layout().dropdownWithoutImage(
                        "Selecione o Núcleo", nucleo, mudarNucleo, nucleosSnapshot.data, context);
                  }),
              SizedBox(
                height: 20,
              ),
              nucleoFoiSelecionado
                  ? FutureBuilder<List<String>>(
                      future: dataEntregaFuture,
                      builder: (context, nucleosSnapshot) {
                        switch (nucleosSnapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            return Layout().dropdownWithoutImage(
                                "Carregando Datas...", dataEntrega, null, [], context);
                          case ConnectionState.done:
                            if (nucleosSnapshot.hasData) {
                              return Layout().dropdownWithoutImage("Selecione a Data de Entrega",
                                  dataEntrega, mudarDataEntrega, dataEntregaList, context);
                            }
                            return Center(
                                child: Text(
                                    "Não foi possivel recuperar as datas de entrega.\nVerifique sua conexão e tente novamente"));
                          case ConnectionState.none:
                            return Center(
                                child: Text(
                                    "Não foi possivel recuperar datas de entrega..\nVerifique sua conexão e tente novamente"));
                        }
                        return Layout().dropdownWithoutImage("Selecione a Data de Entrega",
                            dataEntrega, mudarDataEntrega, dataEntregaList, context);
                      })
                  : Layout().dropdownWithoutImage(
                      "Selecione a Data de Entrega", dataEntrega, null, [], context),
              SizedBox(
                height: 20,
              ),
              dataEntregaFoiSelecionada
                  ? FutureBuilder<List<String>>(
                      future: entidadeFuture,
                      builder: (context, entidadesSnapshot) {
                        switch (entidadesSnapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            return Layout().dropdownWithoutImage("Carregando Entidades...",
                                entidadeSelecionadaIDNome, null, [], context);
                          case ConnectionState.done:
                            if (entidadesSnapshot.hasData) {
                              return Layout().dropdownWithoutImage(
                                  "Selecione a Entidade",
                                  entidadeSelecionadaIDNome,
                                  mudarEntidade,
                                  entidadesSnapshot.data,
                                  context);
                            }
                            return Center(
                                child: Text(
                                    "Não foi possivel recuperar as entidades."));
                          case ConnectionState.none:
                            return Center(
                                child: Text(
                                    "Não foi possivel recuperar as entidades.\nVerifique sua conexão e tente novamente"));
                        }
                        return Layout().dropdownWithoutImage(
                            "Selecione a Entidades",
                            entidadeSelecionadaIDNome,
                            mudarEntidade,
                            entidadesSnapshot.data,
                            context);
                      })
                  : Layout().dropdownWithoutImage("Selecione a Entidade", entidadeSelecionadaIDNome,
                      null, [], context),
              SizedBox(
                height: 20,
              ),
              entidadeFoiSelecionada
                  ? Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: firebasePesagemStream,
                          builder: (context, pesagemSnapshot) {
                            switch (pesagemSnapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Layout().botaosimples(
                                            text: "Adicionar Pesagem", function: null!),
                                        Layout().botaosimples(text: "Concluir", function: null!),
                                      ],
                                    ),
                                    Center(child: CircularProgressIndicator()),
                                  ],
                                );
                              default:
                                if (pesagemSnapshot.hasData &&
                                    pesagemSnapshot.data!.docs.isNotEmpty) {
                                  pesagemListOfMaps.clear();
                                  pesagemSnapshot.data!.docs.first['pesagens'].forEach((element) {
                                    pesagemListOfMaps.add(element);
                                  });
                                  convertPesagemMapsToObject();
                                  return Column(
                                    children: [
                                      entidadeFoiSelecionada
                                          ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Layout().botaosimples(
                                                    text: "Adicionar Pesagem",
                                                    function: () {
                                                      adicionarPesagem(pesagemSnapshot);
                                                    }),
                                                pesagemList.isNotEmpty
                                                    ? Layout().botaosimples(
                                                        color: Colors.green,
                                                        text: "Concluir",
                                                        function: () {
                                                          Navigator.of(context).pop();
                                                        })
                                                    : Layout().botaosimples(
                                                        text: "Concluir", function: null!),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Layout().botaosimples(text: "Adicionar Pesagem", function: null!),Layout().botaosimples(text: "Concluir", function: null!),
                                              ],
                                            ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: pesagemList.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            CorEContraCor corEcontraCor = TampinhaCores()
                                                .colorFromString(pesagemList[index].corTampinha);
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 7),
                                              child: Container(
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black45),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: GestureDetector(
                                                  onLongPress: () {
                                                    showDialog(
                                                        context: context,
                                                        barrierDismissible: true,
                                                        builder: (BuildContext context) {
                                                          return EditOrDeleteDialog(
                                                            pesagemList[index],
                                                            pesagemList,
                                                            index,
                                                            pesagemSnapshot.data!.docs.first,
                                                            valorTampinhaMap,
                                                          );
                                                        });
                                                  },
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
                                                                style: TextStyle(
                                                                    color: corEcontraCor.contraCor),
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
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Center(
                                            child: Column(
                                          children: [
                                            Text(
                                              "Peso Total: ${pesagemSnapshot.data!.docs.first['pesototal']} kg",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(60, 60, 60, 1)),
                                            ),
                                            pesagemSnapshot.data!.docs.first['valortotal'] != null ? Text(
                                              "Valor Total: ${formatCurrency.format(pesagemSnapshot.data!.docs.first['valortotal'])} ",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(60, 60, 60, 1)),
                                            ): Container(),
                                          ],
                                        )),
                                      )
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    entidadeFoiSelecionada
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Layout().botaosimples(
                                                  text: "Adicionar Pesagem",
                                                  function: () {
                                                    adicionarPesagem(pesagemSnapshot);
                                                  }),
                                              pesagemList.isNotEmpty
                                                  ? Layout().botaosimples(
                                                      color: Colors.green,
                                                      text: "Concluir",
                                                      function: () {
                                                        Navigator.of(context).pop();
                                                      }): Layout().botaosimples(text: "Concluir", function: null!),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Layout().botaosimples(text: "Adicionar Pesagem", function: null!),
                                              Layout().botaosimples(text: "Concluir", function: null!),
                                            ],
                                          ),
                                    Expanded(child: Center(child: Text('Sem Itens'))),
                                  ],
                                );
                            }
                          }),
                    )
                  : Container(),
            ],
          ),
        ));
  }

  void adicionarPesagem(AsyncSnapshot<QuerySnapshot> pesagemSnapshot) {
   DocumentSnapshot? pesagemDoc;
    if(pesagemSnapshot!=null && pesagemSnapshot.hasData && pesagemSnapshot.data!.docs.isNotEmpty){
      pesagemDoc = pesagemSnapshot.data!.docs.first;
    }
    pesagemParcial!.nucleoID = nucleoSelecionadoID!;
    pesagemParcial!.nucleoNome = nucleo!;
    pesagemParcial!.entidadeID = entidadeSelecionadaID!;
    pesagemParcial!.entidadeNome = entidadeSelecionadaNome!;
    pesagemParcial!.data = DateFormat('dd/MM/yyyy').parse(dataEntrega!);
    pesagemParcial!.entregaID = entregaID!;
    pesagemParcial!.recicladorID = recicladorSelecionadoID!;
    pesagemParcial!.recicladorNome = recicladorSelecionado!;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PesagemDialog(pesagemParcial!, pesagemList, pesagemDoc!, valorTampinhaMap,editIndex: 0,editar: false,);
        });
  }
}

class PesagemObject {
  PesagemObject(
      { this.peso=0.0,
        this.valor=0.0,
        this.nucleoID=0,
        this.corTampinha='',
        required this.data,
        this.entidadeNome='',
        this.nucleoNome='',
        this.entidadeID=0,
        this.entregaID=0,
        this.recicladorID=0,
        this.recicladorNome=''
      });
  double peso;
  double valor;
  String corTampinha;
  int entregaID;
  int nucleoID;
  int entidadeID;
  int recicladorID;
  String recicladorNome;
  String entidadeNome;
  String nucleoNome;
  DateTime data;
}
