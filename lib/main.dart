import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=eb58dc40';

//tentar adicionar outras meoedas por meio pop-up box

void main() async {

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar;
  double euro;

  void _clearAll(){
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text){
  double real = double.parse(text);
  if(text.isEmpty) {
    _clearAll();
    return;
  }
  dollarController.text = (real/dollar).toStringAsFixed(2);
  euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dollarChanged(String text){
    double dollar = double.parse(text);
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    //a razao do this.dollar se da pelo fato de transformar o dolar anterior para reais
    euroController.text = ((dollar * this.dollar)/euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    double euro = double.parse(text);
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro/dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _clearAll,
          )
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text('Carregando dados...',
                  style: TextStyle(color: Colors.amber, fontSize: 20.0),
                  textAlign: TextAlign.center,)
                );
              default:
                if(snapshot.hasError){
                  return Center(
                    child: Text('Erro ao carregando dados...',
                      style: TextStyle(color: Colors.amber, fontSize: 20.0),
                      textAlign: TextAlign.center,)
                  );
                } else{

                  dollar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on, size: 140.0, color: Colors.amber),
                        Divider(),
                        buildTextField('Reais', 'R\$ ', realController, _realChanged),
                        Divider(),
                        buildTextField('Dólares', 'US\$ ', dollarController, _dollarChanged),
                        Divider(),
                        buildTextField('Euros', '€ ', euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f){ //para evitar a repetiçao do codigo
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix //Colocar o simbolo/nome dentro do campo de texto
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 20.0
    ),
    keyboardType: TextInputType.numberWithOptions(decimal: true), //somente numeros no campo
    onChanged: f, //sempre que o campo for alterado, vai chamar a funçao f
  );
}