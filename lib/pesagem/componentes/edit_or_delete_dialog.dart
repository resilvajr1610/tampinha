import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tampinha/pesagem/novaentrega.dart';

import 'pesagemdialog.dart';

class EditOrDeleteDialog extends StatefulWidget {
  final PesagemObject pesagem;
  final List<PesagemObject> pesagemList;
  final DocumentSnapshot pesagemDoc;
  final Map<String, dynamic> valorTampinhaMap;

  final int editIndex;

  const EditOrDeleteDialog(this.pesagem, this.pesagemList, this.editIndex, this.pesagemDoc, this.valorTampinhaMap);
  @override
  _EditOrDeleteDialogState createState() => _EditOrDeleteDialogState();
}

class _EditOrDeleteDialogState extends State<EditOrDeleteDialog> {
  @override
  void initState() {
    super.initState();
  }

  void openEditDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PesagemDialog(
            widget.pesagem,
            widget.pesagemList,
            widget.pesagemDoc,
            widget.valorTampinhaMap,
            editar: true,
            editIndex: widget.editIndex,
          );
        });
  }

  void deletarItem() {
    Map<String, dynamic> map = Map<String, dynamic>();
    List<dynamic> pesagemListOfMap = [];

    pesagemListOfMap = widget.pesagemDoc['pesagens'];
    pesagemListOfMap.removeAt(widget.editIndex);


    double pesoTotal = 0;
    double valorTotal = 0;
    pesagemListOfMap.forEach((element) {
      pesoTotal += element['peso'];
      valorTotal +=element['valor'];
    });

    map['pesototal'] = pesoTotal;
    map['valortotal'] = valorTotal;
    map['pesagens'] = pesagemListOfMap;
    widget.pesagemDoc.reference.update(map);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                  flex: 1,
                  child: InkWell(
                      onTap: openEditDialog,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          "Editar",
                          textAlign: TextAlign.center,
                        ),
                      ))),
              Flexible(
                  flex: 1,
                  child: InkWell(
                      onTap: deletarItem,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          "Deletar",
                          textAlign: TextAlign.center,
                        ),
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}
