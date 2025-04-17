import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mysql1/mysql1.dart' as mysql;

import 'mysql_conexao.dart';
part 'entidadesassistenciais_controller.g.dart';

class EntidadesAssistenciaisController = _EntidadesAssistenciaisControllerBase with _$EntidadesAssistenciaisController;
 
abstract class _EntidadesAssistenciaisControllerBase with Store {
  @observable 
  var entidadesList = ObservableList<mysql.ResultRow>();

  @observable
  String atividadeSelecionada = 'Todas as Atividades';

  @observable
  String estadoSelecionado = 'Todos os Estados';

  @observable
  String cidadeSelecionada = 'Todas as Cidades';

  @observable
  var cidadesList = ObservableList<String>();

  @observable
  var estadosList = ObservableList<String>();

  @observable
  var atividadesList = ObservableList<String>(); 

  var settings;
  static const word = 'Tod';
  static Map<int, String> menuAtividades = {
    1: 'Idosos',
    2: 'Crianças',
    3: 'Mulher',
    4: 'Animais',
    5: 'Raciais',
    6: 'Indigenas',
    7: 'LGBT',
    8: 'Deficiência Intelectual',
    9: 'Deficiência Visual',
    10: 'Deficiência Motora',
    11: 'Dependência Química',
    12: 'Meio Ambiente',
    13: 'Educação',
    14: 'Empreendedorismo',
    15: 'Saúde',
    16: 'Outros'
  };
  _EntidadesAssistenciaisControllerBase() {
    conectardb();
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
    var conn = await mysql.MySqlConnection.connect(settings);
    var results = await conn.query('select * from entidades where EntDel = 0 and EntPesoTotal != 0');
    for (var row in results) {
      entidadesList.add(row);
    }

    results = await conn.query('select distinct EntAtividade from entidades where EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntAtividade ASC');
    atividadesList.add('Todas as Atividades');
    for (var row in results) {
      if(int.parse(row.fields['EntAtividade'].toString()) > 0 && int.parse(row.fields['EntAtividade'].toString()) <=16){
      atividadesList.add(row.fields['EntAtividade'].toString());
      }
    }
    atividadesList.sort((str1,str2){  
      if(!str1.contains(word) && !str2.contains(word)){
      if(menuAtividades[int.parse(str1.toString())]!.compareTo(menuAtividades[int.parse(str2.toString())]!) == 1){
        return 1;
      }else{
        return -1;
      }
      }
      return 0;
    });

    results = await conn.query(
        'select distinct EntCidade from entidades where EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntCidade ASC');
    cidadesList.add('Todas as Cidades');
    for (var row in results) {
      cidadesList.add(row.fields['EntCidade'].toString());
    }

    results = await conn.query('select distinct EntEstado from entidades where EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntEstado ASC');
    estadosList.add('Todos os Estados');
    for (var row in results) {
      estadosList.add(row.fields['EntEstado'].toString());
    }

    await conn.close();
  }

  @action
  dynamic changeAtividade(value) async {
    atividadeSelecionada = value;
    if (!atividadeSelecionada.contains(word)) {
      var conn = await mysql.MySqlConnection.connect(settings);
      var results = await conn.query(
          "select distinct EntEstado from entidades where EntAtividade = '$atividadeSelecionada' and EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntEstado ASC");
      estadoSelecionado = 'Todos os Estados';
      estadosList.clear();
      estadosList.add('Todos os Estados');
      for (var row in results) {
        estadosList.add(row.fields['EntEstado'].toString());
      }
      results = await conn.query(
          "select distinct EntCidade from entidades where EntAtividade = '$atividadeSelecionada' and EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntCidade ASC");
      cidadeSelecionada = 'Todas as Cidades';
      cidadesList.clear();
      cidadesList.add('Todas as Cidades');
      for (var row in results) {
        cidadesList.add(row.fields['EntCidade'].toString());
      }
      await conn.close();
    } else {
      var conn = await mysql.MySqlConnection.connect(settings);
      var results = await conn.query(
          "select distinct EntEstado from entidades where EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntEstado ASC");
      estadoSelecionado = 'Todos os Estados';
      estadosList.clear();
      estadosList.add('Todos os Estados');
      for (var row in results) {
        estadosList.add(row.fields['EntEstado'].toString());
      }
      results = await conn.query(
          'select distinct EntCidade from entidades where EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntCidade ASC');
      cidadeSelecionada = 'Todas as Cidades';
      cidadesList.clear();
      cidadesList.add('Todas as Cidades');
      for (var row in results) {
        cidadesList.add(row.fields['EntCidade'].toString());
      }
      await conn.close();
    }
  }

  @action
  Future<dynamic> changeEstado(value) async {
    estadoSelecionado = value;
    if (!estadoSelecionado.contains(word.toString())) {
      var conn = await mysql.MySqlConnection.connect(settings);
      if(!atividadeSelecionada.contains(word)){
      cidadesList.clear();  
      var results = await conn.query(
          "select distinct EntCidade from entidades where EntEstado = '$estadoSelecionado' and EntAtividade= '$atividadeSelecionada' and EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntCidade ASC");    
      cidadeSelecionada = 'Todas as Cidades';
      cidadesList.add('Todas as Cidades');
      for (var row in results) {
        cidadesList.add(row.fields['EntCidade']);
      }
      }else{
        cidadesList.clear();  
      var results = await conn.query(
          "select distinct EntCidade from entidades where EntEstado = '$estadoSelecionado' and EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntCidade ASC");    
      cidadeSelecionada = 'Todas as Cidades';
      cidadesList.add('Todas as Cidades');
      for (var row in results) {
        cidadesList.add(row.fields['EntCidade']);
      }
      }
      await conn.close();
    } else {
      cidadesList.clear();
      var conn = await mysql.MySqlConnection.connect(settings);
      var results = await conn.query(
          "select distinct EntCidade from entidades where EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0 order by EntCidade ASC");
      cidadeSelecionada = 'Todas as Cidades';
      cidadesList.add('Todas as Cidades');
      for (var row in results) {
        cidadesList.add(row.fields['EntCidade']);
      }
      await conn.close();
    }
  }

  @action
  String changeCidade(dynamic value) {
    return cidadeSelecionada = value;
  }

  @action
  aplicarFiltros() async {
    var conn = await mysql.MySqlConnection.connect(settings);
    if (!atividadeSelecionada.contains(word.toString()) ||
        !estadoSelecionado.contains(word.toString()) ||
        !cidadeSelecionada.contains(word.toString())) {
      if (!atividadeSelecionada.contains(word.toString()) &&
          !estadoSelecionado.contains(word.toString()) &&
          !cidadeSelecionada.contains(word.toString())) {
        //Todos filtros usados
        var results = await conn.query(
            "select EntLogo,EntSigla, EntSite from entidades where EntAtividade = '$atividadeSelecionada' and EntEstado = '$estadoSelecionado' and EntCidade = '$cidadeSelecionada' and EntStatus = 2  and EntDel = 0 and EntPesoTotal != 0");
        entidadesList.clear();
        for (var row in results) {
          entidadesList.add(row);
        }
      } else {
        if (!atividadeSelecionada.contains(word.toString()) &&
            !estadoSelecionado.contains(word.toString())) {
          //Somente atividade e estado
          var results = await conn.query(
              "select EntLogo,EntSigla, EntSite from entidades where EntAtividade = '$atividadeSelecionada' and EntEstado = '$estadoSelecionado' and EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0");
          entidadesList.clear();
          for (var row in results) {
            entidadesList.add(row);
          }
        } else {
          if (!atividadeSelecionada.contains(word.toString()) &&
              !cidadeSelecionada.contains(word.toString())) {
            //Somente atividade e cidade
            var results = await conn.query(
                "select EntLogo,EntSigla, EntSite from entidades where EntAtividade = '$atividadeSelecionada' and EntCidade = '$cidadeSelecionada' and EntStatus = 2 and EntDel = 0 and EntPesoTotal != 0");
            entidadesList.clear();
            for (var row in results) {
              entidadesList.add(row);
            }
          } else {
            if (!estadoSelecionado.contains(word.toString()) &&
                !cidadeSelecionada.contains(word.toString())) {
              //Somente estado e cidade
              var results = await conn.query(
                  "select EntLogo,EntSigla, EntSite from entidades where EntEstado = '$estadoSelecionado' and EntCidade = '$cidadeSelecionada' and EntStatus = 2 and EntDel = 0 and EntPesoTotal != 0");
              entidadesList.clear();
              for (var row in results) {
                entidadesList.add(row);
              }
            } else {
              if (!estadoSelecionado.contains(word.toString())) {
                //Somente estado
                var results = await conn.query(
                    "select EntLogo,EntSigla, EntSite from entidades where EntEstado = '$estadoSelecionado' and EntStatus = 2 and EntDel = 0 and EntPesoTotal != 0");
                entidadesList.clear();
                for (var row in results) {
                  entidadesList.add(row);
                }
              }
              if (!atividadeSelecionada.contains(word.toString())) {
                //Somente atividade
                var results = await conn.query(
                    "select EntLogo,EntSigla, EntSite from entidades where EntAtividade = '$atividadeSelecionada' and EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0");
                entidadesList.clear();
                for (var row in results) {
                  entidadesList.add(row);
                }
              }
              if (!cidadeSelecionada.contains(word.toString())) {
                //Somente cidade
                var results = await conn.query(
                    "select EntLogo,EntSigla, EntSite from entidades where EntCidade = '$cidadeSelecionada' and EntStatus = 2 and EntDel = 0 and EntPesoTotal != 0");
                entidadesList.clear();
                for (var row in results) {
                  entidadesList.add(row);
                }
              }
            }
          }
        }
      }
    } else {
      var results = await conn.query(
          'select * from entidades where EntDel = 0 and EntStatus = 2 and EntPesoTotal != 0');
      entidadesList.clear();
      for (var row in results) {
        entidadesList.add(row);
      }
    }
    await conn.close();
  }

  dialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Filtrar por Atividade, Estado e Cidade.'),
            content: Column(children: [
              Card(
                elevation: 0.0,
                color: Colors.white54,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 55.0,
                  child: Observer(builder: (_) {
                    return DropdownButton(
                      isExpanded: true,
                      value: atividadeSelecionada,
                      hint: Text('Selecione uma atividade'),
                      items: atividadesList.map((String value) {
                        String? atividade = value.contains(word)
                            ? 'Todas as Atividades'
                            : menuAtividades[int.parse(value.toString())] !=
                                    null
                                ? menuAtividades[int.parse(value)]
                                : 'Outros';
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: new Text(
                              atividade!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: changeAtividade!,
                    );
                  }),
                ),
              ),
              Card(
                elevation: 0.0,
                color: Colors.white54,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 55.0,
                  child: Observer(builder: (_) {
                    return DropdownButton(
                        isExpanded: true,
                        value: estadoSelecionado,
                        items: estadosList.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: new Text(
                                value,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: changeEstado!);
                  }),
                ),
              ),
              Card(
                elevation: 0.0,
                color: Colors.white54,
                child: Container(
                  height: 55.0,
                  child: Observer(builder: (_) {
                    return DropdownButton(
                      isExpanded: true,
                      value: cidadeSelecionada,
                      items: cidadesList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: new Text(
                              value,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: changeCidade!,
                    );
                  }),
                ),
              ),
            ]),
            actions: <Widget>[
              ElevatedButton(
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text(
                  'Aplicar',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  await aplicarFiltros();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
