import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/fornecedores/fornecedores_detalhes_page.dart';
import 'package:front_mercado/pages/fornecedores/fornecedores_form_page.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class FornecedoresPage extends StatefulWidget {
  const FornecedoresPage({super.key});

  @override
  State<FornecedoresPage> createState() => _FornecedoresPageState();
}

class _FornecedoresPageState extends State<FornecedoresPage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _fornecedores = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarFornecedores();
    super.initState();
  }

  Future<void> _listarFornecedores([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .get(Uri.http(
              apiUrl,
              query != null && query != ''
                  ? '/Fornecedores/nomeECnpj/$query'
                  : '/Fornecedores'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _fornecedores =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar fornecedores: ${response.statusCode}');
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

  Future<void> _adicionarFornecedor(Map<String, dynamic> fornecedor) async {
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Fornecedores'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(fornecedor),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarFornecedores();
      } else {
        _mostrarErro('Erro ao adicionar fornecedor: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _editarFornecedor(Map<String, dynamic> fornecedor) async {
    try {
      final response = await http
          .put(
            Uri.http(apiUrl, '/Fornecedores'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(fornecedor),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarFornecedores();
      } else {
        _mostrarErro('Erro ao editar fornecedor: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioFornecedor({Map<String, dynamic>? fornecedor}) async {
    final fornecedorRecebido = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FornecedorFormPage(
          fornecedor: fornecedor,
        ),
      ),
    );

    if (fornecedorRecebido == null) return;
    if (fornecedorRecebido.containsKey('idFornecedor')) {
      await _editarFornecedor(fornecedorRecebido);
    } else {
      await _adicionarFornecedor(fornecedorRecebido);
    }
  }

  void _pesquisarFornecedores() {
    _listarFornecedores(_pesquisaController.text);
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
        title: const Text('Fornecedores'),
      ),
      drawer: const DrawerFenomenos(),
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
                    onSubmitted: (_) =>
                        _pesquisarFornecedores(), // Adicionado para executar ao pressionar Enter
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _pesquisarFornecedores,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _fornecedores.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_fornecedores[index]['nome']),
                        subtitle: Text(_fornecedores[index]['cnpj']),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FornecedorDetalhesPage(
                                fornecedor: _fornecedores[index],
                              ),
                            ),
                          );
                          _listarFornecedores();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioFornecedor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
