
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tampinha/controllers/userlogin_controller.dart';
import 'package:tampinha/firebaseAnonymousLogin/FirebaseAnonymousAuth.dart';

import 'layout.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  AnimationController? controller, controller1;
  Animation<double>? fade;
  Animation<double>? buttonSqueeze;
  Animation<double>? textOpacity;
  Animation<double>? offset;

  TextEditingController csenha = TextEditingController();
  TextEditingController cemail = TextEditingController();

  UserLoginController? userLoginController;

  bool _obscurePassword = true;

  final AuthService _auth = AuthService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userLoginController = Provider.of<UserLoginController>(context);
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Duration(seconds: 4));
    controller1 = AnimationController(vsync: this, duration: Duration(seconds: 2));
    controller!.addStatusListener((status) {});
    controller1!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        userLoginController!.loginAsAdmin(cemail.text, csenha.text).then((value) async {
          controller1!.reset();
          if (value == true) {
            dynamic result = await _auth.signInAnon();
            result == null ? print('User não logado')
            : print('User logado');
            Navigator.of(context).pop();
          } else {
            Layout().dialog1botao(context, "Oops!",
                "Não foi possível realizar o login\nVerifique suas credencias e tente novamente");
          }
        });

        // loginUser().then((user) {
        //   controller1.reset();
        // });
      }
    });
    controller!.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    controller1!.dispose();
    cemail.dispose();
    csenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    offset = Tween(begin: MediaQuery.of(context).size.width, end: 0.0).animate(CurvedAnimation(
        parent: controller!, curve: Interval(0.0, 0.85, curve: Curves.easeInOutQuad)));
    fade = Tween(begin: 0.0, end: MediaQuery.of(context).size.width).animate(
        CurvedAnimation(parent: controller!, curve: Interval(0.0, 0.7, curve: Curves.ease)));
    buttonSqueeze = Tween(begin: MediaQuery.of(context).size.width / 2, end: 60.0)
        .animate(CurvedAnimation(parent: controller1!, curve: Interval(0.0, 0.5)));
    textOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller!, curve: Interval(0.0, 1.0, curve: Curves.easeInCirc)));
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
        ),
        body: Row(
          children: [
            (MediaQuery.of(context).size.width > 850)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                  )
                : Container(),
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: AnimatedBuilder(
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(offset!.value, 0.0),
                                  child: Image.asset("images/logo.png", width: fade!.value),
                                );
                              },
                              animation: controller!,
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              AnimatedBuilder(
                                builder: (context, child) {
                                  return Opacity(
                                      opacity: textOpacity!.value,
                                      child: Layout().caixadetexto(1, 1, TextInputType.emailAddress,
                                          cemail, "login", TextCapitalization.none));
                                },
                                animation: controller!,
                              ),
                              AnimatedBuilder(
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: textOpacity!.value,
                                    child: Layout().caixadetexto(
                                        1,
                                        1,
                                        TextInputType.visiblePassword,
                                        csenha,
                                        "senha",
                                        TextCapitalization.none,
                                        showObscureOption: true,
                                        obscureTextValue: _obscurePassword,
                                        obscureFunction: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        }),
                                  );
                                },
                                animation: controller!,
                              ),
                              AnimatedBuilder(
                                builder: (context, child) {
                                  return Opacity(
                                      opacity: textOpacity!.value, child: loginAnimation());
                                },
                                animation: controller!,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            (MediaQuery.of(context).size.width > 850)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                  )
                : Container(),
          ],
        ));
  }

  Widget loginAnimation() {
    return AnimatedBuilder(
        animation: controller1!,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Container(
              width: buttonSqueeze!.value,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Card(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.all(10.0),
                elevation: 5.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15.0),
                  splashColor: Colors.grey.withAlpha(30),
                  onTap: () async {
                    if (csenha.text.isNotEmpty && cemail.text.isNotEmpty) {
                      controller1!.forward();
                    } else {
                      return Layout().dialog1botao(context, "E-mail e senha",
                          "Preencha dados válidos.\nCaso tenha esquecido a senha, escreva o e-mail e clique em Recuperar Senha");
                    }
                  },
                  child: buttonSqueeze!.value >= 125
                      ? Center(
                          child: Text(
                          "ACESSAR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 1.5, color: Colors.white, fontWeight: FontWeight.w400),
                        ))
                      : Container(
                          alignment: Alignment.center,
                          width: buttonSqueeze!.value,
                          height: 45.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 1.0,
                          )),
                ),
              ),
            ),
          );
        });
  }
}
