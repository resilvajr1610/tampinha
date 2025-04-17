// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'pontosdecoleta_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PontosdeColetaController on _PontosdeColetaControllerBase, Store {
  final _$locationAtom = Atom(name: '_PontosdeColetaControllerBase.location');

  @override
  places.Location get location {
    _$locationAtom.reportRead();
    return super.location;
  }

  @override
  set location(places.Location value) {
    _$locationAtom.reportWrite(value, super.location, () {
      super.location = value;
    });
  }

  final _$positionAtom = Atom(name: '_PontosdeColetaControllerBase.position');

  @override
  CameraPosition get position {
    _$positionAtom.reportRead();
    return super.position;
  }

  @override
  set position(CameraPosition value) {
    _$positionAtom.reportWrite(value, super.position, () {
      super.position = value;
    });
  }

  final _$markersAtom = Atom(name: '_PontosdeColetaControllerBase.markers');

  @override
  ObservableList<Marker> get markers {
    _$markersAtom.reportRead();
    return super.markers;
  }

  @override
  set markers(ObservableList<Marker> value) {
    _$markersAtom.reportWrite(value, super.markers, () {
      super.markers = value;
    });
  }

  final _$entidadesRowsAtom =
      Atom(name: '_PontosdeColetaControllerBase.entidadesRows');

  @override
  ObservableList<mysql.ResultRow> get entidadesRows {
    _$entidadesRowsAtom.reportRead();
    return super.entidadesRows;
  }

  @override
  set entidadesRows(ObservableList<mysql.ResultRow> value) {
    _$entidadesRowsAtom.reportWrite(value, super.entidadesRows, () {
      super.entidadesRows = value;
    });
  }

  final _$entidadesAtom = Atom(name: '_PontosdeColetaControllerBase.entidades');

  @override
  Map<String, int> get entidades {
    _$entidadesAtom.reportRead();
    return super.entidades;
  }

  @override
  set entidades(Map<String, int> value) {
    _$entidadesAtom.reportWrite(value, super.entidades, () {
      super.entidades = value;
    });
  }

  final _$entidadeSelecionadaAtom =
      Atom(name: '_PontosdeColetaControllerBase.entidadeSelecionada');

  @override
  String get entidadeSelecionada {
    _$entidadeSelecionadaAtom.reportRead();
    return super.entidadeSelecionada;
  }

  @override
  set entidadeSelecionada(String value) {
    _$entidadeSelecionadaAtom.reportWrite(value, super.entidadeSelecionada, () {
      super.entidadeSelecionada = value;
    });
  }

  final _$suggestionsAtom =
      Atom(name: '_PontosdeColetaControllerBase.suggestions');

  @override
  ObservableList<String> get suggestions {
    _$suggestionsAtom.reportRead();
    return super.suggestions;
  }

  @override
  set suggestions(ObservableList<String> value) {
    _$suggestionsAtom.reportWrite(value, super.suggestions, () {
      super.suggestions = value;
    });
  }

  final _$getEntidadesAsyncAction =
      AsyncAction('_PontosdeColetaControllerBase.getEntidades');

  @override
  Future getEntidades() {
    return _$getEntidadesAsyncAction.run(() => super.getEntidades());
  }

  final _$conectardbAsyncAction =
      AsyncAction('_PontosdeColetaControllerBase.conectardb');

  @override
  Future conectardb() {
    return _$conectardbAsyncAction.run(() => super.conectardb());
  }

  final _$getUserLocationAsyncAction =
      AsyncAction('_PontosdeColetaControllerBase.getUserLocation');

  @override
  Future getUserLocation() {
    return _$getUserLocationAsyncAction.run(() => super.getUserLocation());
  }

  final _$placesAutoCompleteAsyncAction =
      AsyncAction('_PontosdeColetaControllerBase.placesAutoComplete');

  @override
  Future placesAutoComplete(BuildContext context, places.Prediction prediction) {
    return _$placesAutoCompleteAsyncAction
        .run(() => super.placesAutoComplete(context, prediction));
  }

  final _$getCoordenadasAsyncAction =
      AsyncAction('_PontosdeColetaControllerBase.getCoordenadas');

  @override
  Future getCoordenadas(String rua, String numero, String cidade) {
    return _$getCoordenadasAsyncAction
        .run(() => super.getCoordenadas(rua, numero, cidade));
  }

  final _$aplicarFiltrosAsyncAction =
      AsyncAction('_PontosdeColetaControllerBase.aplicarFiltros');

  @override
  Future aplicarFiltros() {
    return _$aplicarFiltrosAsyncAction.run(() => super.aplicarFiltros());
  }

  final _$_PontosdeColetaControllerBaseActionController =
      ActionController(name: '_PontosdeColetaControllerBase');

  @override
  dynamic changeDropdown(value) {
    final _$actionInfo = _$_PontosdeColetaControllerBaseActionController
        .startAction(name: '_PontosdeColetaControllerBase.changeDropdown');
    try {
      return super.changeDropdown(value);
    } finally {
      _$_PontosdeColetaControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
location: ${location},
position: ${position},
markers: ${markers},
entidadesRows: ${entidadesRows},
entidades: ${entidades},
entidadeSelecionada: ${entidadeSelecionada},
suggestions: ${suggestions}
    ''';
  }
}
