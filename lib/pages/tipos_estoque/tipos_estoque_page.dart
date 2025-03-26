import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/tipos_estoque/tipos_estoque_detalhes_page.dart';
import 'package:front_mercado/pages/tipos_estoque/tipos_estoque_form_page.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class TiposEstoquePage extends StatefulWidget {
  const TiposEstoquePage({super.key});

  @override
  State<TiposEstoquePage> createState() => _TiposEstoquePageState();
}

class _TiposEstoquePageState extends State<TiposEstoquePage> {
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _tiposEstoque = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarTiposEstoque();
    super.initState();
  }

  Future<void> _listarTiposEstoque([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = query != null && query != ''
          ? await http
              .post(
                Uri.http(apiUrl, '/TiposEstoque/descricao'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({'query': query}),
              )
              .timeout(const Duration(seconds: 15))
          : await http
              .get(
                Uri.http(apiUrl, '/TiposEstoque'),
              )
              .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _tiposEstoque =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar tipos de estoque: ${response.statusCode}');
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

  void _abrirFormularioTipoEstoque({Map<String, dynamic>? tipoEstoque}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TipoEstoqueFormPage(tipoEstoque: tipoEstoque),
      ),
    );
    _listarTiposEstoque();
  }

  void _pesquisarTiposEstoque() {
    _listarTiposEstoque(_pesquisaController.text);
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
        title: const Text('Tipos de Estoque'),
      ),
      drawer: const DrawerFenomenos('Tipos de Estoque'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesquisaController,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _pesquisarTiposEstoque(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _pesquisarTiposEstoque,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tiposEstoque.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_tiposEstoque[index]['descricao']),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TiposEstoqueDetalhesPage(
                                tipoEstoque: _tiposEstoque[index],
                              ),
                            ),
                          );
                          _listarTiposEstoque();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioTipoEstoque(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
