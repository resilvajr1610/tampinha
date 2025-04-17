import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tampinha/design.dart';
import 'package:tampinha/pesagem/editarentrega.dart';
import 'package:tampinha/pesagem/novaentrega.dart';
import 'package:tampinha/pesagem/sobre.dart';
import 'package:mysql1/mysql1.dart' as mysql;

import '../layout.dart';

class Pesagem extends StatefulWidget {
  @override
  _PesagemState createState() => _PesagemState();
}

class _PesagemState extends State<Pesagem> {
  Stream<QuerySnapshot>? pesagemStream;

  DateTime? dataSelecionada;
  String? dataSelecionadaStr;
  bool dataEntregaFoiSelecionada = false;
  List<String> dataEntregaList = [];
  Future<List<String>>? datasEntregaFuture;
  double? valorTotalEntrega, pesoTotalEntrega;
  String? nucleoSelecionado;
  int? nucleoSelecionadoID;
  bool nucleoFoiSelecionado = false;
  Future<List<String>>? nucleosFuture;
  Map<String, int> nucleosMap = Map<String, int>();

  mysql.MySqlConnection? sqlConnection;
  bool connectionInitialized = false;

  bool enviandoPesagens = false;

  Future<String>? entregaStatusFuture;

  String? statusEntrega;

  final formatCurrency = new NumberFormat.simpleCurrency(locale: 'pt_BR');

  Future<void> initConnection() async {
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    sqlConnection = await mysql.MySqlConnection.connect(settings);
  }

  Future<void> mudarNucleo(String text) async {
    setState(() {
      nucleoSelecionado = text;
      nucleoSelecionadoID = nucleosMap[nucleoSelecionado];
      dataEntregaFoiSelecionada = false;
      dataSelecionada = null;
      dataSelecionadaStr = null;
      nucleoFoiSelecionado = true;
      datasEntregaFuture = pesquisarDatasEntrega();
    });
  }

  Future<void> mudarData(String text) async {
    setState(() {
      dataSelecionadaStr = text;
      dataSelecionada = DateFormat('dd/MM/yyyy').parse(dataSelecionadaStr!);
      pesagemStream = pesagemQuery();
      entregaStatusFuture = pesquisarEntregaStatus();
    });
  }

  Future<void> adicionarEntregaNoBancoDeDados(DocumentSnapshot pesagemDoc,
      double valorTotal, double pesoTotal, int quantidatePesagens) async {
    if (sqlConnection == null) {
      await initConnection();
    }

    await sqlConnection!.query('''UPDATE entregas
           SET EntrValorTotal = ?, EntrPesoTotal = ?, EntrNumPesagens = ?
           WHERE EntrID = ${pesagemDoc['entregaid']}''', [

      valorTotal,
      pesoTotal,
      quantidatePesagens,
    ]);
    return;
  }

  List<PesagemObject> convertPesagemMapsToObject(
      List<dynamic> pesagemListOfMaps) {
    List<PesagemObject> pesagemList = [];

    pesagemListOfMaps.forEach((element) {
      PesagemObject pesagemAux = PesagemObject(
          peso: element['peso'].toDouble(),
          corTampinha: element['tampinhacor'],
          valor: element['valor'],
          data: DateTime.now()
      );
      pesagemList.add(pesagemAux);
    });
    return pesagemList;
  }

  Future<List<int>> adicionarPesagensNoBancoDeDados(
      DocumentSnapshot pesagemDoc) async {
    if (sqlConnection == null) {
      await initConnection();
    }

    String data = pesagemDoc['data'];
    String entidade = pesagemDoc['entidade'];
    int nucleoID = pesagemDoc['nucleoid'];
    int entidadeID = pesagemDoc['entidadeid'];
    int entregaID = pesagemDoc['entregaid'];

    List<int> pesagensID = [];

    List<PesagemObject> pesagemList =
        convertPesagemMapsToObject(pesagemDoc['pesagens']);

    pesagemList.forEach((pesagemElement) async {
      mysql.Results ? queryResult = await sqlConnection!.query(
          'insert into pesagens '
          '(PesIDNucleo, PesIDEntrega, PesIDEntidade, PesNomeEntidade, PesPeso, PesCor, PesValor, PesData) '
          'values (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            nucleoID,
            entregaID,
            entidadeID,
            entidade,
            pesagemElement.peso,
            pesagemElement.corTampinha,
            pesagemElement.valor,
            DateFormat('dd/MM/yyyy').parse(data).toUtc()
          ]);
      print("INSERT TO pesagens TABLE. ID = ${queryResult.insertId}");
      pesagensID.add(queryResult!.insertId!);
    });
    return pesagensID;
  }

  void concluirPesagem(QuerySnapshot pesagemSnapshot) async {
    enviandoPesagens = true;
    try {
      await initConnection();
      List<String> pesagensEnviadasID = [];

      int numeroDePesagens = 0;
      for (int i = 0; i < pesagemSnapshot!.docs.length; i++) {

        await adicionarPesagensNoBancoDeDados(pesagemSnapshot.docs[i]);
        pesagemSnapshot.docs[i].reference
            .update({'status': StatusPesagem.ENTREGA_ENVIADA});
        pesagensEnviadasID.add(pesagemSnapshot.docs[i].id);
        pesagemSnapshot.docs[i]['pesagens'].forEach((element) {
          numeroDePesagens++;
        });
      }
      await adicionarEntregaNoBancoDeDados(
          pesagemSnapshot.docs.first,
          valorTotalEntrega!,
          pesoTotalEntrega!,
          numeroDePesagens);

      Map<String, dynamic> entregasMap = Map<String, dynamic>();
      entregasMap['data'] = pesagemSnapshot.docs.first['data'];
      entregasMap['entregaid'] = pesagemSnapshot.docs.first['entregaid'];
      entregasMap['status'] = StatusEntrega.ENTREGA_ENVIADA;
      entregasMap['nucleo'] = pesagemSnapshot.docs.first['nucleonome'];
      entregasMap['nucleoid'] = pesagemSnapshot.docs.first['nucleoid'];
      entregasMap['pesagens'] = pesagensEnviadasID;

      await FirebaseFirestore.instance
          .collection(ColecoesNomes.ENTREGAS)
          .add(entregasMap);
      sqlConnection?.close();
      sqlConnection = null;
      setState(() {
        entregaStatusFuture = pesquisarEntregaStatus();
      });
    } catch (e) {
      enviandoPesagens = false;
    }
    enviandoPesagens = false;
  }

  Future<String> pesquisarEntregaStatus() async {
    try {
      QuerySnapshot entregaQuery = await FirebaseFirestore.instance
          .collection(ColecoesNomes.ENTREGAS)
          .where('data', isEqualTo: dataSelecionadaStr)
          .where('nucleoid', isEqualTo: nucleoSelecionadoID)
          .get();
      if (entregaQuery == null || entregaQuery.docs.isEmpty || entregaQuery.docs.first['status'] == StatusEntrega.PENDENTE ) {
        return StatusEntrega.PENDENTE;
      } else
        return StatusEntrega.ENTREGA_ENVIADA;
    } catch (e) {
      return StatusEntrega.DESCONHECIDO;
    }
  }

  Future<List<String>> pesquisarDatasEntrega() async {
    await initConnection();

    DateTime lastDate = DateTime.now().subtract(Duration(days: 90));
    String lastDate_str = DateFormat('yyyy-MM-dd').format(lastDate);

    DateTime today = DateTime.now().add(Duration(days: 1));
    String today_str = DateFormat('yyyy-MM-dd').format(today);

    mysql.Results dataEntregaQuery = await sqlConnection!.query(
        "select distinct CAST(Horario AS date) from agenda_horarios WHERE NucleoID = $nucleoSelecionadoID AND Horario > '$lastDate_str' AND Horario <= '$today_str' ORDER BY Horario DESC");

    dataEntregaList.clear();
    for (var row in dataEntregaQuery) {
      DateTime date = row[0];
      String formattedDate = DateFormat('dd/MM/yyyy').format(date);
      dataEntregaList.add(formattedDate);
    }

    setState(() {
      dataSelecionadaStr = dataEntregaList.first;
      entregaStatusFuture = pesquisarEntregaStatus();
      pesagemStream = pesagemQuery();
    });

    sqlConnection?.close();
    sqlConnection = null;
    return dataEntregaList;
  }

  Future<List<String>> pesquisarNucleos() async {
    await initConnection();

    mysql.Results nucleosQuery =
        await sqlConnection!.query("select * from nucleos ORDER BY NucleoNome");

    nucleosMap.clear();
    for (var row in nucleosQuery) {
      nucleosMap[row['NucleoNome']] = row['NucleoID'];
    }
    sqlConnection?.close();
    sqlConnection = null;
    return nucleosMap.keys.toList();
  }

  Stream<QuerySnapshot> pesagemQuery() {
    setState(() {
      dataEntregaFoiSelecionada = true;
    });
    return FirebaseFirestore.instance
        .collection(ColecoesNomes.PESAGEM)
        .where('data', isEqualTo: dataSelecionadaStr)
        .where('nucleoid', isEqualTo: nucleoSelecionadoID)
        .orderBy('entidade')
        .snapshots();
  }

  @override
  void initState() {
    dataEntregaList.clear();
    nucleosFuture = pesquisarNucleos();
    super.initState();
  }

  @override
  void dispose() {
    sqlConnection?.close();
    sqlConnection = null;
    connectionInitialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 15.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Sobre()));
                  },
                  color: Colors.black,
                  icon: Icon(Icons.info_outline),
                  iconSize: 30,
                ),
              ),
            )
          ],
        ),
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
                        child: Layout().logoextendido(
                            "images/logo.png",
                            MediaQuery.of(context).size.height * 0.1,
                            0.4,
                            context)),
                  ),
                  Expanded(
                    child: Layout().textosimples(
                        "Pesagem",
                        MediaQuery.of(context).size.height * 0.03,
                        FontWeight.bold,
                        0.0,
                        Colors.blue[700],
                        Colors.transparent),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Layout()
                      .botaoret("Criar/Editar Entrega", NovaEntrega(), context),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              borderRadius: BorderRadius.circular(12)),
                          child: entregasWidget()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget listaDePesagens(AsyncSnapshot<QuerySnapshot> pesagemSnapshot) {
    if (pesagemSnapshot.hasData) {
      return ListView.builder(
          itemCount: pesagemSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 15, left: 15),
              child: entregaItemWidget(pesagemSnapshot.data!.docs[index]),
            );
          });
    }
    if (pesagemSnapshot.hasError) {
      return Center(child: Text("Erro ao recuperar lista de pesagens"));
    }
    return Center(child: Text("Sem Itens"));
  }

  Widget botaoEnviarEntrega(AsyncSnapshot<QuerySnapshot> pesagemSnapshot) {
    return FutureBuilder<String>(
        future: entregaStatusFuture,
        builder: (context, statusFuture) {
         if (statusFuture.connectionState == ConnectionState.waiting) {
           return Center(child: CircularProgressIndicator());
         }
          if (statusFuture.hasData) {
           if (statusFuture.data == StatusEntrega.PENDENTE) {
              return InkWell(
                onTap: () {
                  if (enviandoPesagens == false) {
                    concluirPesagem(pesagemSnapshot.data!);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, -3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Enviar Entrega",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )),
                ),
              );
         }
            return Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(60, 60, 60, 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, -3), // changes position of shadow
                  ),
                ],
              ),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Pesagens já foram enviadas",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
            );
          } else {
            return Text('Não foi possível recuperar a entrega');
          }
        });
  }

  Widget entregasWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Flexible(
                flex:1,
                child: FutureBuilder<List<String>>(
                    future: nucleosFuture,
                    builder: (context, nucleosSnapshot) {
                      switch (nucleosSnapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return Layout().dropdownWithoutImage(
                              "Carregando Núcleos...",
                              nucleoSelecionado,
                              null,
                              [],
                              context);
                        case ConnectionState.done:
                          if (nucleosSnapshot.hasData) {
                            return Layout().dropdownWithoutImage(
                                "Selecione o Núcleo",
                                nucleoSelecionado,
                                mudarNucleo,
                                nucleosSnapshot.data,
                                context);
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
                          "Selecione o Núcleo",
                          nucleoSelecionado,
                          mudarNucleo,
                          nucleosSnapshot.data,
                          context);
                    }),
              ),
              nucleoFoiSelecionado
                  ? Flexible(
                flex:1,
                child: FutureBuilder<List<String>>(
                        future: datasEntregaFuture,
                        builder: (context, datasSnapshot) {
                          switch (datasSnapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                              return Layout().dropdownWithoutImage(
                                  "Carregando Datas...",
                                  dataSelecionadaStr,
                                  null,
                                  [],
                                  context);
                            case ConnectionState.done:
                              if (datasSnapshot.hasData) {
                                return Layout().dropdownWithoutImage(
                                    "Selecione a data",
                                    dataSelecionadaStr,
                                    mudarData,
                                    datasSnapshot.data,
                                    context);
                              }
                              return Center(
                                  child: Text(
                                      "Não foi possivel recuperar as datas.\nVerifique sua conexão e tente novamente"));
                            case ConnectionState.none:
                              return Center(
                                  child: Text(
                                      "Não foi possivel recuperar as datas.\nVerifique sua conexão e tente novamente"));
                          }
                          return Layout().dropdownWithoutImage(
                              "Selecione a  Data",
                              dataSelecionadaStr,
                              mudarData,
                              datasSnapshot.data,
                              context);
                        }),
                  )
                  : Flexible(
                flex: 1,
                    child: Layout().dropdownWithoutImage("Selecione a Data",
                        dataSelecionadaStr, null, [], context),
                  ),
            ],
          ),
        ),
        dataEntregaFoiSelecionada ?
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream: pesagemStream,
              builder: (context, pesagemSnapshot) {
                switch (pesagemSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                     valorTotalEntrega =somaValorEntrega(pesagemSnapshot.data!);
                     pesoTotalEntrega =somaPesoEntrega(pesagemSnapshot.data!);
                    return Column(
                      children: [
                        Expanded(child: listaDePesagens(pesagemSnapshot)),
                        SizedBox(
                          height: 8,
                        ),
                        pesoTotalEntrega != null
                            ? Text(
                                'Peso Total: ${pesoTotalEntrega!.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : Container(),
                        valorTotalEntrega != null
                            ? Text(
                                'Valor Total: ${valorTotalEntrega!.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold))
                            : Container(),
                        SizedBox(
                          height: 8,
                        ),
                        botaoEnviarEntrega(pesagemSnapshot),
                      ],
                    );
                }
              }),
        ) :
            Container()
      ],
    );
  }

  Widget entregaItemWidget(DocumentSnapshot pesagemDoc) {
    TextStyle pesagemInfoTextStyle = TextStyle(fontSize: 15);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditarEntrega(pesagemDoc: pesagemDoc)));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Núcleo ${pesagemDoc['nucleoid']}: ${pesagemDoc['nucleonome']}",
                style: pesagemInfoTextStyle,
              ),
              Text(
                "Entidade ${pesagemDoc['entidadeid']}: ${pesagemDoc['entidade']}",
                style: pesagemInfoTextStyle,
              ),
              Text(
                "Data: ${pesagemDoc['data']}",
                style: pesagemInfoTextStyle,
              ),
              Text(
                "Peso: Kg ${pesagemDoc['pesototal']}",
                style: pesagemInfoTextStyle,
              ),
              Text(
                "Valor: ${formatCurrency.format(pesagemDoc['valortotal'])}",
                style: pesagemInfoTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }


  double somaValorEntrega(QuerySnapshot pesagemQuery) {
    double sum = 0;
    pesagemQuery.docs.forEach((element) {
      sum += element['valortotal'] ?? 0;
    });
    return sum;
  }

  double somaPesoEntrega(QuerySnapshot pesagemQuery) {
    double sum = 0;
    pesagemQuery.docs.forEach((element) {
      sum += element['pesototal'] ?? 0;
    });
    return sum;
  }
}
