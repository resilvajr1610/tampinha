// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entidadesassistenciais_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$EntidadesAssistenciaisController
    on _EntidadesAssistenciaisControllerBase, Store {
  final _$entidadesListAtom =
      Atom(name: '_EntidadesAssistenciaisControllerBase.entidadesList');

  @override
  ObservableList<mysql.ResultRow> get entidadesList {
    _$entidadesListAtom.reportRead();
    return super.entidadesList;
  }

  @override
  set entidadesList(ObservableList<mysql.ResultRow> value) {
    _$entidadesListAtom.reportWrite(value, super.entidadesList, () {
      super.entidadesList = value;
    });
  }

  final _$atividadeSelecionadaAtom =
      Atom(name: '_EntidadesAssistenciaisControllerBase.atividadeSelecionada');

  @override
  String get atividadeSelecionada {
    _$atividadeSelecionadaAtom.reportRead();
    return super.atividadeSelecionada;
  }

  @override
  set atividadeSelecionada(String value) {
    _$atividadeSelecionadaAtom.reportWrite(value, super.atividadeSelecionada,
        () {
      super.atividadeSelecionada = value;
    });
  }

  final _$estadoSelecionadoAtom =
      Atom(name: '_EntidadesAssistenciaisControllerBase.estadoSelecionado');

  @override
  String get estadoSelecionado {
    _$estadoSelecionadoAtom.reportRead();
    return super.estadoSelecionado;
  }

  @override
  set estadoSelecionado(String value) {
    _$estadoSelecionadoAtom.reportWrite(value, super.estadoSelecionado, () {
      super.estadoSelecionado = value;
    });
  }

  final _$cidadeSelecionadaAtom =
      Atom(name: '_EntidadesAssistenciaisControllerBase.cidadeSelecionada');

  @override
  String get cidadeSelecionada {
    _$cidadeSelecionadaAtom.reportRead();
    return super.cidadeSelecionada;
  }

  @override
  set cidadeSelecionada(String value) {
    _$cidadeSelecionadaAtom.reportWrite(value, super.cidadeSelecionada, () {
      super.cidadeSelecionada = value;
    });
  }

  final _$cidadesListAtom =
      Atom(name: '_EntidadesAssistenciaisControllerBase.cidadesList');

  @override
  ObservableList<String> get cidadesList {
    _$cidadesListAtom.reportRead();
    return super.cidadesList;
  }

  @override
  set cidadesList(ObservableList<String> value) {
    _$cidadesListAtom.reportWrite(value, super.cidadesList, () {
      super.cidadesList = value;
    });
  }

  final _$estadosListAtom =
      Atom(name: '_EntidadesAssistenciaisControllerBase.estadosList');

  @override
  ObservableList<String> get estadosList {
    _$estadosListAtom.reportRead();
    return super.estadosList;
  }

  @override
  set estadosList(ObservableList<String> value) {
    _$estadosListAtom.reportWrite(value, super.estadosList, () {
      super.estadosList = value;
    });
  }

  final _$atividadesListAtom =
      Atom(name: '_EntidadesAssistenciaisControllerBase.atividadesList');

  @override
  ObservableList<String> get atividadesList {
    _$atividadesListAtom.reportRead();
    return super.atividadesList;
  }

  @override
  set atividadesList(ObservableList<String> value) {
    _$atividadesListAtom.reportWrite(value, super.atividadesList, () {
      super.atividadesList = value;
    });
  }

  final _$conectardbAsyncAction =
      AsyncAction('_EntidadesAssistenciaisControllerBase.conectardb');

  @override
  Future conectardb() {
    return _$conectardbAsyncAction.run(() => super.conectardb());
  }

  final _$changeAtividadeAsyncAction =
      AsyncAction('_EntidadesAssistenciaisControllerBase.changeAtividade');

  @override
  Future changeAtividade(value) {
    return _$changeAtividadeAsyncAction.run(() => super.changeAtividade(value));
  }

  final _$changeEstadoAsyncAction =
      AsyncAction('_EntidadesAssistenciaisControllerBase.changeEstado');

  @override
  Future changeEstado(value) {
    return _$changeEstadoAsyncAction.run(() => super.changeEstado(value));
  }

  final _$aplicarFiltrosAsyncAction =
      AsyncAction('_EntidadesAssistenciaisControllerBase.aplicarFiltros');

  @override
  Future aplicarFiltros() {
    return _$aplicarFiltrosAsyncAction.run(() => super.aplicarFiltros());
  }

  final _$_EntidadesAssistenciaisControllerBaseActionController =
      ActionController(name: '_EntidadesAssistenciaisControllerBase');

  @override
  String changeCidade(value) {
    final _$actionInfo =
        _$_EntidadesAssistenciaisControllerBaseActionController.startAction(
            name: '_EntidadesAssistenciaisControllerBase.changeCidade');
    try {
      return super.changeCidade(value);
    } finally {
      _$_EntidadesAssistenciaisControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
entidadesList: ${entidadesList},
atividadeSelecionada: ${atividadeSelecionada},
estadoSelecionado: ${estadoSelecionado},
cidadeSelecionada: ${cidadeSelecionada},
cidadesList: ${cidadesList},
estadosList: ${estadosList},
atividadesList: ${atividadesList}
    ''';
  }
}
