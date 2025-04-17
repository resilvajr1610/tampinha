import 'package:mobx/mobx.dart';
import 'package:mysql1/mysql1.dart' as mysql;

import '../design.dart';
import 'mysql_conexao.dart';

part 'userlogin_controller.g.dart';

class UserLoginController = _UserLoginControllerBase
    with _$UserLoginController;

abstract class _UserLoginControllerBase with Store {

  //OBSERVABLES
  @observable
  bool isLoggedIn = false;
  @observable
  String loggedInAs = "";

  _UserLoginControllerBase();

  @action
  logOut() {
    isLoggedIn = false;
    loggedInAs = "";
  }

  @action
  Future<bool> loginAsAdmin(String loginAdmin, String senhaDigitada) async {
    var settings = new mysql.ConnectionSettings(
      host: MysqlConexao().url,
      port: MysqlConexao().porta,
      user: MysqlConexao().login,
      password: MysqlConexao().senha,
      db: MysqlConexao().db,
    );
    var conn = await mysql.MySqlConnection.connect(settings);

    mysql.Results loginAdminDB = await conn
        .query("select distinct senhanormal from admin where login = '$loginAdmin'");

    String? senhaBD;
    for (var row in loginAdminDB) {
      senhaBD = row[0].toString();
    }

    print("senha BD: $senhaBD");

    if(senhaBD == senhaDigitada){
      isLoggedIn = true;
      loggedInAs = UserLoggedAs.LOGGED_AS_ADMIN;
      print("USER_LOGGED IN");
    } else{
      print("OOPS! senhas não coincidem");
    }
    await conn.close();
    return isLoggedIn;
  }
}
