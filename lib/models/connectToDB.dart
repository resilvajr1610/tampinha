import 'package:mysql1/mysql1.dart';
import '../controllers/mysql_conexao.dart';
import 'ConnectToSQL.dart';

class SQL implements ConnectToSQL {
  final ConnectionSettings _settings;

  MySqlConnection? _conn;

  SQL()
      : _settings = ConnectionSettings(
    host: MysqlConexao().url,
    port: MysqlConexao().porta,
    user: MysqlConexao().login,
    password: MysqlConexao().senha,
    db: MysqlConexao().db,
  );

  Future<void> connectToDB() async {
    try {
      _conn = await MySqlConnection.connect(_settings);
    } catch (e) {
      // Trate o erro adequadamente (lançando exceções personalizadas, por exemplo).
      print('Erro ao conectar ao banco de dados: $e');
    }
  }

  Future<void> closeConnection() async {
    if (_conn != null) {
      try {
        await _conn!.close();
      } catch (e) {
        print('Erro ao fechar a conexão com o banco de dados: $e');
      }
    }
  }

  MySqlConnection getConn() {
    if (_conn == null) {
      throw Exception('Não foi possível obter a conexão com o banco de dados. Certifique-se de chamar connectToDB() primeiro.');
    }
    return _conn!;
  }
}
