import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/estoques/estoques_detalhes_page.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _estoque = [];
  List<Map<String, dynamic>> _estoqueFiltrado = [];
  List<Map<String, dynamic>> _tiposEstoque = [];
  String? _tipoSelecionado;
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _carregarTiposEstoqueEListar();
    super.initState();
  }

  _carregarTiposEstoqueEListar() async {
    await _carregarTiposEstoque();
    await _listarEstoque();
  }

  Future<void> _carregarTiposEstoque() async {
    try {
      final response = await http.get(
        Uri.http(apiUrl, '/TiposEstoque'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _tiposEstoque = [
            {'descricao': 'Todos'} // Adiciona a opção "Todos"
          ];
          _tiposEstoque.addAll(
              List<Map<String, dynamic>>.from(json.decode(response.body)));
        });
      } else {
        _mostrarErro('Erro ao carregar tipos de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
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
          _estoqueFiltrado = _estoque;  // Inicializa com todos os itens
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

  void _filtrarEstoque() {
    String query = _pesquisaController.text.toLowerCase();

    setState(() {
      _estoqueFiltrado = _estoque.where((estoque) {
        final descricaoMatch = estoque['descricaoEstoque']
            .toLowerCase()
            .contains(query);
        final tipoMatch = _tipoSelecionado == null ||
            _tipoSelecionado == 'Todos' || // Inclui todos os estoques
            estoque['descricaoTipoEstoque'] == _tipoSelecionado;
        return descricaoMatch && tipoMatch;
      }).toList();
    });
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
      drawer: const DrawerFenomenos('Estoques'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesquisaController,
                    decoration: InputDecoration(
                      labelText: 'Pesquisar por Descrição',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _filtrarEstoque, // Pesquisa ao clicar na lupa
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _filtrarEstoque(), // Pesquisa ao pressionar Enter
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tipoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Estoque',
                      border: OutlineInputBorder(),
                    ),
                    items: _tiposEstoque.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo['descricao'],
                        child: Text(tipo['descricao']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _tipoSelecionado = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _estoqueFiltrado.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(_estoqueFiltrado[index]['descricaoEstoque']),
                          leading: Text('${_estoqueFiltrado[index]['idEstoque']}'),
                          trailing: Text(_estoqueFiltrado[index]['descricaoTipoEstoque']),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EstoqueDetalhesPage(
                                  estoque: _estoqueFiltrado[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}