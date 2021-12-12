import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscar CEP via API',
      debugShowCheckedModeBanner: false,
      home: HomeCep(),
    );
  }
}

class HomeCep extends StatelessWidget {
  const HomeCep({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar CEP via API'),
      ),
      body: ListView(
        children: <Widget>[
          CepForm(),
        ],
      ),
    );
  }
}

class CepForm extends StatefulWidget {
  const CepForm({Key? key}) : super(key: key);

  @override
  _CepFormState createState() => _CepFormState();
}

class _CepFormState extends State<CepForm> {
  var _numberCep = TextEditingController();

  String _resultado = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _numberCep,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            maxLength: 8,
            style: const TextStyle(
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              icon: Icon(Icons.map_outlined),
              labelText: 'Informe o número do CEP',
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: () async {
                String cep = _numberCep.text;
                if (cep.length != 8) {
                  setState(() {
                    _resultado = "";
                  });
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Atenção'),
                          content:
                              const Text('Por favor, digite um CEP válido!'),
                          actions: <Widget>[
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ok')),
                          ],
                        );
                      });
                  return;
                }
                try {
                  String url = "https://viacep.com.br/ws/${cep}/json/";

                  http.Response response;

                  response = await http.get(Uri.parse(url));

                  Map<String, dynamic> data = json.decode(response.body);

                  String zipCode = data['cep'];
                  String address =
                      data['logradouro'].isEmpty ? '-' : data['logradouro'];
                  String city = data['localidade'];
                  String neighborhood =
                      data['bairro'].isEmpty ? '-' : data['bairro'];
                  String uf = data['uf'];

                  setState(() {
                    _resultado =
                        "${zipCode}: ${address}, ${neighborhood}, ${city} - ${uf}";
                  });
                } catch (e) {
                  setState(() {
                    _resultado = "";
                  });
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Atenção'),
                          content: const Text('CEP não encontrado!'),
                          actions: <Widget>[
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ok')),
                          ],
                        );
                      });
                  return;
                }
              },
              child: Text(' Buscar ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  )),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            _resultado,
            style: TextStyle(
              color: Colors.orange,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
