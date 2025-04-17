import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'controllers/userlogin_controller.dart';
import 'login.dart';

class Layout {
  Widget logoextendido(image, altura, larguraperc, context) {
    return Container(
      width: MediaQuery.of(context).size.width * larguraperc,
      height: altura,
      decoration: BoxDecoration(
          image:
              DecorationImage(image: AssetImage(image), fit: BoxFit.contain)),
    );
  }

  Widget textosimples(
      texto, size, fontweight, letterspacing, color, backcolor) {
    return Container(
      color: backcolor,
      child: AutoSizeText(
        texto,
        style: TextStyle(
            fontWeight: fontweight,
            letterSpacing: letterspacing,
            fontSize: size,
            color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget menuheader(UserLoginController user, context) {
    return InkWell(
      onLongPress: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      },
      child: UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "images/logomenu.png",
                ),
                fit: BoxFit.contain),
            color: Colors.white,
          ),
          accountEmail: Container(),
          onDetailsPressed: () {
            // if (user.isLoggedIn == null || user.isLoggedIn == false) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
            // }
          },
          accountName: Container()

          // (user.isLoggedIn == true)
          //     ? Align(
          //         alignment: Alignment.bottomRight,
          //         child: InkWell(
          //           onTap: () {
          //             user.logOut();
          //           },
          //           child: Padding(
          //             padding: const EdgeInsets.all(15.0),
          //             child: Text(
          //               'Sair',
          //               style:
          //                   TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red),
          //             ),
          //           ),
          //         ),
          //       )
          //     : Align(
          //         alignment: Alignment.bottomRight,
          //         child: Padding(
          //           padding: const EdgeInsets.all(15),
          //           child: Text("Entrar",
          //               style: TextStyle(
          //                   fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black54)),
          //         ),
          //       ),
          ),
    );
  }

  Widget textonoti(texto, size, fontweight, letterspacing, color, backcolor) {
    return Container(
        color: backcolor,
        child: Linkify(
          onOpen: (link) async {
            if (await canLaunch(link.url)) {
              await launch(link.url);
            } else {
              throw 'Não foi possível abrir: $link';
            }
          },
          text: texto,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: fontweight,
              color: color,
              fontSize: size,
              wordSpacing: 1.5),
        ));
  }

  Widget caixadetexto(
      min, max, textinputtype, controller, placeholder, capitalization,
      {bool obs= false,
      Function? function,
      bool showObscureOption = false,
      bool obscureTextValue = false,
      VoidCallback? obscureFunction}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        obscureText: obscureTextValue,
        minLines: min,
        maxLines: max,
        keyboardType: textinputtype,
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: showObscureOption
              ? IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    obscureTextValue ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: obscureFunction)
              : Container(
                  height: 1,
                  width: 1,
                ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          labelText: placeholder,
          labelStyle: TextStyle(
              letterSpacing: 1.0, fontSize: 12.0, fontWeight: FontWeight.w400),
        ),
        textCapitalization: capitalization,
        autofocus: false,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        // onChanged: function,
      ),
    );
  }

  dialog1botao(context, titulo, texto, {destino}) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(texto),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.amber),
                ),
                onPressed: () {
                  if (destino == null) {
                    Navigator.pop(context);
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => destino),
                        (Route<dynamic> route) => false);
                  }
                },
              ),
            ],
          );
        });
  }



  PreferredSizeWidget  appbarcomumbotao(funcao, nomebarra, nomebotao, context) {
    return AppBar(
      backgroundColor: Colors.amber,
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)),
          ),
          // textColor: Colors.white,
          onPressed: () {
            funcao(context);
          },
          child: Text(
            nomebotao,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          ),
        ),
      ],
      title: Text(nomebarra),
    );
  }

  Widget floatingactionbar(funcao, icon, tip, context) {
    return FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: funcao,
        tooltip: tip,
        child: Icon(icon));
  }

  Widget cardredondo(texto, image, context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        elevation: 5.0,
        child: Container(
          width: 80.0,
          height: 80.0,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.red[700]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 1.0),
                child: Container(
                  width: 40.0,
                  height: MediaQuery.of(context).size.height * 0.04,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(image), fit: BoxFit.contain)),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: textosimples(
                      texto,
                      MediaQuery.of(context).size.height * 0.018,
                      FontWeight.normal,
                      0.3,
                      Colors.black,
                      Colors.transparent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropdownitem(placeholder, selecionado, funcao, lista, context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: selecionado,
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      hint: Center(
        child: AutoSizeText(
          placeholder,
          style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: MediaQuery.of(context).size.height * 0.03),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onChanged: (value) {
        funcao(value);
      },
      items: lista.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                (value == "Brasil")
                    ? Container()
                    : Text(
                        'Estado: ',
                        style: TextStyle(fontSize: 20.0),
                      ),
                AutoSizeText(
                  value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.03),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  height: 25.0,
                  child: new Image.asset(
                    "images/$value.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget dropdownWithoutImage(placeholder, selecionado, funcao, lista, context,
      {fontSize = 19.0}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: DropdownButton<String>(
        isExpanded: true,
        value: selecionado,
        hint: Center(
          child: AutoSizeText(
            placeholder,
            style: funcao != null
                ? TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: fontSize)
                : TextStyle(fontWeight: FontWeight.normal, fontSize: fontSize),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onChanged: (value) {
          funcao(value);
        },
        items: lista.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Center(
              child: AutoSizeText(
                value,
                style: TextStyle(
                    fontWeight: FontWeight.normal, fontSize: fontSize),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  PreferredSizeWidget  appbarcombotaosimples(texto, destino, context) {
    return AppBar(
      centerTitle: true,
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)),
          ),
          onPressed: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => destino));
          },
          child: Text(
            texto,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          ),
        ),
      ],
    );
  }

  Widget botaotodo(image, texto, destino, context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: InkWell(
        onTap: () async {
          if (destino == null) {
            return;
          }
          if (texto == "Pontos de Coleta") {
            if (await Permission.location.request().isGranted) {
              // Either the permission was already granted before or the user just granted it.
            }
            print('aqui');
            Toast.show("Carregando Pontos de Coleta", duration: Toast.lengthLong, gravity: Toast.center);
            // Fluttertoast.showToast(
            //     msg: "Carregando Pontos de Coleta",
            //     toastLength: Toast.LENGTH_LONG,
            //     gravity: ToastGravity.CENTER,
            //     timeInSecForIosWeb: 1,
            //     textColor: Colors.white,
            //     fontSize: 16.0
            // );
          }
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destino));
        },
        child: Container(
          color: Colors.yellow[600],
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (image != null)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                      child: Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(image), fit: BoxFit.contain)),
                      ),
                    )
                  : Container(),
              Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: textosimples(
                      texto,
                      MediaQuery.of(context).size.height * 0.02,
                      FontWeight.w600,
                      0.3,
                      Colors.black,
                      Colors.transparent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget botao(image, texto, destino, context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: Card(
        elevation: 5.0,
        color: Colors.yellow[600],
        child: InkWell(
          onTap: () async {
            if (destino == null) {
              return;
            }
            if (texto == "Pontos de Coleta") {
              if (await Permission.location.request().isGranted) {
                // Either the permission was already granted before or the user just granted it.
              }
              Toast.show("Carregando Mapa", duration: Toast.lengthLong, gravity: Toast.center);
              // Fluttertoast.showToast(
              //     msg: "Carregando Mapa",
              //     toastLength: Toast.LENGTH_LONG,
              //     gravity: ToastGravity.CENTER,
              //     timeInSecForIosWeb: 1,
              //     textColor: Colors.white,
              //     fontSize: 16.0
              // );
            }
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => destino));
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.37,
            child: Column(
              children: <Widget>[
                (image != null)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 1.0),
                        child: Container(
                          width: 40.0,
                          height: MediaQuery.of(context).size.height * 0.04,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(image),
                                  fit: BoxFit.contain)),
                        ),
                      )
                    : Container(),
                Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: textosimples(
                        texto,
                        MediaQuery.of(context).size.height * 0.018,
                        FontWeight.normal,
                        0.3,
                        Colors.black,
                        Colors.transparent)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget botaoret(texto, destino, context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
      child: Card(
        elevation: 5.0,
        color: Colors.yellow[600],
        child: InkWell(
          onTap: () async {
            if (destino == null) {
              return;
            }
            if (texto == "Pontos de Coleta") {
              if (await Permission.location.request().isGranted) {
                // Either the permission was already granted before or the user just granted it.
              }
              // Toast.show("Carregando Mapa", duration: Toast.lengthLong, gravity: Toast.center);
              // Fluttertoast.showToast(
              //     msg: "Carregando Mapa",
              //     toastLength: Toast.LENGTH_LONG,
              //     gravity: ToastGravity.CENTER,
              //     timeInSecForIosWeb: 1,
              //     textColor: Colors.white,
              //     fontSize: 16.0
              // );
            }
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => destino));
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.05,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Center(
                  child: textosimples(
                      texto,
                      MediaQuery.of(context).size.height * 0.02,
                      FontWeight.bold,
                      0.3,
                      Colors.black,
                      Colors.transparent),
                )),
          ),
        ),
      ),
    );
  }

  Widget botaosimples(
      {required String text,
      Color color = Colors.amber,
      required Function function,
      textColor = Colors.white}) {
    return ElevatedButton(
      onPressed:()=> function,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(color),
      ),
      child: AutoSizeText(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget cardfinal(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
      child: Card(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.085,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    const url = 'http://www.tampinhalegal.com.br';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: AutoSizeText(
                    "www.tampinhalegal.com.br",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        const url = 'https://www.facebook.com/tampinhalegal/';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        width: 30.0,
                        height: MediaQuery.of(context).size.height * 0.04,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("images/facebook.png"),
                                fit: BoxFit.contain)),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    InkWell(
                      onTap: () async {
                        const url = 'https://www.instagram.com/tampinhalegal/';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        width: 30.0,
                        height: MediaQuery.of(context).size.height * 0.04,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("images/instagram.png"),
                                fit: BoxFit.contain)),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    InkWell(
                      onTap: () async {
                        const url =
                            'https://www.youtube.com/channel/UCAovmdc4rxAqPwY0OgGc8XA';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        width: 30.0,
                        height: MediaQuery.of(context).size.height * 0.04,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("images/youtube.png"),
                                fit: BoxFit.contain)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<mysql.MySqlConnection> acessarSQL() async {
    var settings = new mysql.ConnectionSettings(
      host: 'tampinhalegal.com.br',
      port: 3306,
      user: 'tampinha_app',
      password: 'T%H_Y@RZtAs+',
      db: 'tampinha_sistema',
    );
    var conn = await mysql.MySqlConnection.connect(settings);
    return conn;
  }
}
