import 'dart:convert';
import 'package:flutter/material.dart';
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
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

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

  void _pesquisarEstoque() {
    String query = _pesquisaController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _estoqueFiltrado = _estoque; // Se não houver pesquisa, mostra todos os itens
      } else {
        _estoqueFiltrado = _estoque
            .where((estoque) => estoque['descricaoEstoque']
                .toLowerCase()
                .contains(query))
            .toList(); // Filtra a lista por descrição
      }
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
      drawer: const DrawerFenomenos(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar por Descrição',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _pesquisarEstoque,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (text) {
                _pesquisarEstoque(); // Atualiza a pesquisa enquanto o usuário digita
              },
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
                          trailing:
                              Text(_estoqueFiltrado[index]['descricaoTipoEstoque']),
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }
}