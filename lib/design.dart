import 'package:flutter/material.dart';

class UserLoggedAs {
  static const String LOGGED_AS_ADMIN = 'logged_as_admin';
  static const String LOGGED_AS_USER = 'logged_as_user';
}

class StatusPesagem {
  static const String PENDENTE = 'pendente';
  static const String ENTREGA_ENVIADA = 'entrega enviada';
}

class StatusEntrega {
  static const String PENDENTE = 'pendente';
  static const String DESCONHECIDO = 'desconhecido';
  static const String ENTREGA_ENVIADA = 'entrega enviada';
}

class ColecoesNomes {
  static const String PESAGEM = 'Pesagem';
  static const String PESAGEM_NUMERO = 'PesagemNumero';
  static const String ENTREGAS = 'Entregas';
}

class TipoInputStory {
  static const int IMAGE_FROM_NETWORK = 0;
  static const int GIF_FROM_NETWORK = 1;
  static const int VIDEO_FROM_NETWORK = 2;
}

class KeysSharedPrefs {
  static const String VISUALIZACAO = 'marcarComoVisto';
  static const String QTD_STORIES = 'qtd_stories';
}


class CorEContraCor {
  CorEContraCor(this.cor, this.contraCor);

  Color cor;
  Color contraCor;
}

class TampinhaCores {
  static const String COR_AZUL = 'Azul';
  static const String COR_AMARELO = 'Amarelo';
  static const String COR_BRANCO = 'Branco';
  static const String COR_CINZA = 'Cinza';
  static const String COR_COLOR = 'Color';
  static const String COR_CRISTAL = 'Cristal';
  static const String COR_DOURADO = 'Dourado';
  static const String COR_FULL = 'Full';
  static const String COR_LARANJA = 'Laranja';
  static const String COR_MARROM = 'Marrom';
  static const String COR_PRETO = 'Preto';
  static const String COR_ROSA = 'Rosa';
  static const String COR_ROXO = 'Roxo';
  static const String COR_VERDE = 'Verde';
  static const String COR_VERMELHO = 'Vermelho';

  CorEContraCor colorFromString(String color) {
    Color? cor;
    Color? contraCor;
    switch (color) {
      case COR_AZUL:
        cor = Colors.blue;
        contraCor = Colors.white;
        break;
      case COR_VERDE:
        cor = Colors.green;
        contraCor = Colors.white;
        break;
      case COR_VERMELHO:
        cor = Colors.red;
        contraCor = Colors.white;
        break;
      case COR_AMARELO:
        cor = Colors.yellow;
        contraCor = Colors.black;
        break;
      case COR_LARANJA:
        cor = Colors.orange;
        contraCor = Colors.white;
        break;
      case COR_ROSA:
        cor = Colors.pink;
        contraCor = Colors.white;
        break;
      case COR_ROXO:
        cor = Colors.purple;
        contraCor = Colors.white;
        break;
      case COR_BRANCO:
        cor = Colors.white;
        contraCor = Colors.black;
        break;
      case COR_CRISTAL:
        cor = Colors.cyan.shade50;
        contraCor = Colors.black;
        break;
      case COR_PRETO:
        cor = Colors.black;
        contraCor = Colors.white;
        break;
      case COR_MARROM:
        cor = Colors.brown;
        contraCor = Colors.white;
        break;
      case COR_CINZA:
        cor = Colors.grey;
        contraCor = Colors.black;
        break;
      case COR_DOURADO:
        cor = Colors.yellowAccent.shade700;
        contraCor = Colors.black;
        break;
      case COR_COLOR:
        cor = Colors.black12;
        contraCor = Colors.black;
        break;
      case COR_FULL:
        cor = Colors.black12;
        contraCor = Colors.black;
        break;
    }
    return CorEContraCor(cor!, contraCor!);
  }
}
