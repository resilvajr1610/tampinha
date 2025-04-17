import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'layout.dart';
import 'controllers/entidadesassistenciais_controller.dart';

class EntidadesAssistenciais extends StatelessWidget {
  var controller;

  @override
  Widget build(BuildContext context) {
    controller = EntidadesAssistenciaisController();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          ElevatedButton(
            child: Text(
              'Pesquisar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              controller.dialog(context);
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/fundo2.png"), fit: BoxFit.cover)),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: Hero(
                          tag: "logo",
                          child: Layout().logoextendido(
                              "images/logo.png",
                              MediaQuery.of(context).size.height * 0.1,
                              0.4,
                              context)),
                    ),
                    Expanded(
                      child: Layout().textosimples(
                          "Entidades Assistenciais",
                          MediaQuery.of(context).size.height * 0.025,
                          FontWeight.bold,
                          0.0,
                          Colors.blue[700],
                          Colors.transparent),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Expanded(
                  child: Observer(builder: (_) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        String image = controller
                            .entidadesList[index].fields['EntLogo']
                            .toString();
                        String sigla = controller
                            .entidadesList[index].fields['EntSigla']
                            .toString();
                        return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                                child: InkWell(
                              onTap: () async {
                                var url = controller
                                    .entidadesList[index].fields['EntSite'];
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  Toast.show('$sigla não possui Site.',duration: Toast.lengthLong);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: image.isNotEmpty && image != 'LOGOOO.jpg'
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            'https://www.tampinhalegal.com.br/sistema/uploads/' +
                                                '$image',
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                                baseColor: Colors.grey,
                                                highlightColor: Colors.yellow,
                                                child: Image.asset(
                                                    'images/logo.png')),
                                        errorWidget: (context, url, error) =>
                                            new Icon(Icons.error),
                                      )
                                    : Center(
                                        child: Text(
                                        '$sigla',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      )),
                              ),
                            )));
                      },
                      itemCount: controller.entidadesList.length,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
