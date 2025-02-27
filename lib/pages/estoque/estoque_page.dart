import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _estoque = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarEstoque();
    super.initState();
  }

  Future<void> _listarEstoque([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .post(
            Uri.http(
                apiUrl,
                query != null && query != ''
                    ? '/Estoques/$query'
                    : '/Estoques/tipo-estoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(<String, String>{'key': 'value'}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _estoque =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar estoque: ${response.statusCode}');
        setState(() {
          _carregando = false;
        });
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
      setState(() {
        _carregando = false;
      });
    }
  }

  void _pesquisarEstoque() {
    _listarEstoque(_pesquisaController.text);
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoques'),
      ),
      drawer: const DrawerFenomenos(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _pesquisaController,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _pesquisarEstoque,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _estoque.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(_estoque[index]['descricaoEstoque']),
                          leading: Text('${_estoque[index]['idEstoque']}'),
                          trailing:
                              Text(_estoque[index]['descricaoTipoEstoque']),
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }
}