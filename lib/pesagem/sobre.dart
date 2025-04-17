import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tampinha/layout.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Sobre extends StatefulWidget {
  @override
  _SobreState createState() => _SobreState();
}

class _SobreState extends State<Sobre> {
  @override
  void initState() {
    super.initState();
  }

  final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.disabled)
  ..loadRequest(Uri.parse("https://www.tampinhalegal.com.br/sistema/app_php/getWebView.php"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Hero(
                        tag: 'logo',
                        child: Layout().logoextendido(
                            "images/logo.png",
                            MediaQuery.of(context).size.height * 0.1,
                            0.4,
                            context)),
                  ),
                  Expanded(
                    child: Layout().textosimples(
                        "Sobre",
                        MediaQuery.of(context).size.height * 0.03,
                        FontWeight.bold,
                        0.0,
                        Colors.blue[700],
                        Colors.transparent),
                  )
                ],
              ),
            ),
            Expanded(
              child: WebViewWidget(
                controller: controller,
              ),
            )
          ],
        ));
  }
}
