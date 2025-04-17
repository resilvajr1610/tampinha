// connect_to_sql.dart

import 'package:mysql1/mysql1.dart';

abstract class ConnectToSQL {
  void connectToDB();
  void closeConnection();
  MySqlConnection getConn();
}
