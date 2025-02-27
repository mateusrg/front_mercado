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
  Map<String, dynamic>? _estoqueSelecionado;
  bool _carregando = false;
  bool _mostrarFiltro = false;

  @override
  void initState() {
    _carregandoEstoquesETiposEstoque();
    super.initState();
  }

  Future<void> _carregandoEstoquesETiposEstoque() async {
    await _listarEstoque();
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

  Future<void> _carregandoEstoques() async {
    final response = await http.get(Uri.http(apiUrl, '/Produtos'));
    if (response.statusCode == 200) {
      setState(() {
        _estoque = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      _mostrarErro('Erro ao carregar produtos: ${response.statusCode}');
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

  void _toggleFiltro() {
    setState(() {
      _mostrarFiltro = !_mostrarFiltro;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoques'),
        actions: [
          IconButton(
            onPressed: _toggleFiltro,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      drawer: const DrawerFenomenos(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (_mostrarFiltro)
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<Map<String, dynamic>>(
                            value: _estoqueSelecionado,
                            decoration:
                                const InputDecoration(labelText: 'Estoques'),
                            items: _estoque.map((estoque) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: estoque,
                                child: Text(estoque['descricao']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _estoqueSelecionado = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
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
