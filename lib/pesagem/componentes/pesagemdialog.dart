import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tampinha/design.dart';
import 'package:tampinha/layout.dart';
import 'package:tampinha/pesagem/novaentrega.dart';

class PesagemDialog extends StatefulWidget {
  final PesagemObject pesagemParcial;
  final List<PesagemObject> pesagemList;
  final bool editar;
  final int editIndex;
  final DocumentSnapshot pesagemDoc;
  final Map<String, dynamic> valorTampinhaMap;

  const PesagemDialog(this.pesagemParcial, this.pesagemList, this.pesagemDoc, this.valorTampinhaMap,
      {this.editar = false, required this.editIndex});
  @override
  _PesagemDialogState createState() => _PesagemDialogState();
}

class _PesagemDialogState extends State<PesagemDialog> {
  static const String SELECIONE_A_COR = "SELECIONE A COR";

  TextEditingController pesoTextController = TextEditingController();
  double valor = 0;
  bool showErrorMessage = false;
  String errorMessage = "";

  String? corTampinha;
  final List<String> coresList = [
    SELECIONE_A_COR,
    TampinhaCores.COR_AMARELO,
    TampinhaCores.COR_AZUL,
    TampinhaCores.COR_BRANCO,
    TampinhaCores.COR_CINZA,
    TampinhaCores.COR_COLOR,
    TampinhaCores.COR_CRISTAL,
    TampinhaCores.COR_DOURADO,
    TampinhaCores.COR_FULL,
    TampinhaCores.COR_LARANJA,
    TampinhaCores.COR_MARROM,
    TampinhaCores.COR_PRETO,
    TampinhaCores.COR_ROSA,
    TampinhaCores.COR_ROXO,
    TampinhaCores.COR_VERDE,
    TampinhaCores.COR_VERMELHO,
  ];

  @override
  void initState() {
    showErrorMessage = false;
    if (widget.editar == true) {
      pesoTextController.text = widget.pesagemList[widget.editIndex].peso.toString();
      corTampinha = widget.pesagemList[widget.editIndex].corTampinha;
      valor = widget.pesagemList[widget.editIndex].valor;
    }
    super.initState();
  }

  @override
  void dispose() {
    pesoTextController.dispose();
    super.dispose();
  }

  calcularValor() {
    if (pesoTextController.text.isNotEmpty && corTampinha != null && corTampinha!.isNotEmpty) {
      double _peso = double.parse(pesoTextController.text);
      double _valorDaCor = widget.valorTampinhaMap[corTampinha];
      valor = _peso * _valorDaCor;
   
    }
    else {
      valor=0;
    }
  }

  void mudarCor(String text) {
    setState(() {
      corTampinha = text;
      showErrorMessage = false;
      calcularValor();
    });
  }

  void editarPesagem() async {
    if (pesoTextController.text != null &&
        pesoTextController.text.isNotEmpty &&
        corTampinha != null &&
        corTampinha!.isNotEmpty &&
        corTampinha != SELECIONE_A_COR) {
      Map<String, dynamic> map = Map<String, dynamic>();
      List<dynamic> pesagemListOfMap = [];

      if (widget.pesagemDoc != null) {
        pesagemListOfMap = widget.pesagemDoc['pesagens'];

        pesagemListOfMap[widget.editIndex] = {
          'peso': double.parse(pesoTextController.text),
          'tampinhacor': corTampinha,
          'valor': valor,
        };

        double pesoTotal = 0;
        double valorTotal = 0;
        pesagemListOfMap.forEach((element) {
          pesoTotal += element['peso'];
          valorTotal += element['valor'];
        });

        map['pesototal'] = pesoTotal;
        map['valortotal'] = valorTotal;
        map['pesagens'] = pesagemListOfMap;
        widget.pesagemDoc.reference.update(map);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        setState(() {
          errorMessage = "Erro: Documento não encontrado";
          showErrorMessage = true;
        });
      }
    } else {
      setState(() {
        errorMessage = "Cor e Peso devem ser preenchidos obrigatoriamente";
        showErrorMessage = true;
      });
    }
  }

  void adicionarPesagem() async {
    if (pesoTextController.text != null &&
        pesoTextController.text.isNotEmpty &&
        corTampinha != null &&
        corTampinha!.isNotEmpty &&
        corTampinha != SELECIONE_A_COR) {
      Map<String, dynamic> map = Map<String, dynamic>();
      List<dynamic> pesagemListOfMap = [];

      if (widget.pesagemDoc != null) {
        pesagemListOfMap = widget.pesagemDoc['pesagens'];
        pesagemListOfMap.add({
          'peso': double.parse(pesoTextController.text),
          'tampinhacor': corTampinha,
          'valor': valor,
        });

        double pesoTotal = 0;
        double valorTotal = 0;
        pesagemListOfMap.forEach((element) {
          pesoTotal += element['peso'];
          valorTotal += element['valor'];
        });


        map['pesototal'] = pesoTotal;
        map['valortotal'] = valorTotal;
        map['pesagens'] = pesagemListOfMap;
        widget.pesagemDoc.reference.update(map);
        Navigator.of(context).pop();
      } else {
        pesagemListOfMap.clear();
        pesagemListOfMap.add({
          'peso': double.parse(pesoTextController.text),
          'tampinhacor': corTampinha,
          'valor': valor,
        });

        double pesoTotal = 0;
        double valorTotal = 0;
        pesagemListOfMap.forEach((element) {
          pesoTotal += element['peso'];
          valorTotal += element['valor'];
        });

        DocumentSnapshot pesagemNumeroDoc = await FirebaseFirestore.instance
            .collection(ColecoesNomes.PESAGEM_NUMERO)
            .doc('pesagemnumero')
            .get();
        Map<String, dynamic> pesagemNumeroMap = Map<String, dynamic>();
        pesagemNumeroMap['pesagemnumero'] = pesagemNumeroDoc['pesagemnumero'] + 1;
        pesagemNumeroDoc.reference.update(pesagemNumeroMap);

        map['pesagemnumero'] = pesagemNumeroDoc['pesagemnumero'];
        map['pesototal'] = pesoTotal;
        map['valortotal'] = valorTotal;
        map['data'] = DateFormat('dd/MM/yyyy').format(widget.pesagemParcial.data);
        map['datacomparar'] = widget.pesagemParcial.data;
        map['entidade'] = widget.pesagemParcial.entidadeNome;
        map['nucleoid'] = widget.pesagemParcial.nucleoID;
        map['entidadeid'] = widget.pesagemParcial.entidadeID;
        map['nucleonome'] = widget.pesagemParcial.nucleoNome;
        map['entregaid'] = widget.pesagemParcial.entregaID;
        map['recicladorid'] = widget.pesagemParcial.recicladorID;
        map['recicladornome'] = widget.pesagemParcial.recicladorNome;
        map['pesagens'] = pesagemListOfMap;
        map['status'] = StatusPesagem.PENDENTE;
       FirebaseFirestore.instance.collection(ColecoesNomes.PESAGEM).add(map);
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        errorMessage = "Cor e Peso devem ser preenchidos obrigatoriamente";
        showErrorMessage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                Layout().dropdownWithoutImage(
                    "Selecione a Cor", corTampinha, mudarCor, coresList, context),
                SizedBox(
                  height: 20,
                ),
                Layout().caixadetexto(1, 1, TextInputType.numberWithOptions(decimal: true), pesoTextController, "Peso (Kg)",
                    TextCapitalization.none, function: () {
                  setState(() {
                    calcularValor();
                    showErrorMessage = false;
                  });
                }),
                SizedBox(
                  height: 20,
                ),
                Text('Valor = ${valor.toStringAsFixed(2)}'),
                SizedBox(
                  height: 20,
                ),
                showErrorMessage
                    ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      )
                    : Container(),
                showErrorMessage
                    ? SizedBox(
                        height: 20,
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Layout().botaosimples(
                          text: "Cancelar",
                          function: () {
                            Navigator.of(context).pop();
                            if (widget.editar) Navigator.of(context).pop();
                          },
                          color: Colors.blueGrey),
                      Spacer(),
                      widget.editar
                          ? Layout().botaosimples(
                              text: "Editar", function: editarPesagem, color: Colors.green)
                          : Layout().botaosimples(
                              text: "Adicionar", function: adicionarPesagem, color: Colors.green),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
