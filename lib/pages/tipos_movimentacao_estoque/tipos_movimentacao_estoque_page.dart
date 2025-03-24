import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/tipos_movimentacao_estoque/tipos_movimentacao_estoque_detalhes_page.dart';
import 'package:front_mercado/pages/tipos_movimentacao_estoque/tipos_movimentacao_estoque_form.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class TiposMovimentacoesEstoquePage extends StatefulWidget {
  const TiposMovimentacoesEstoquePage({super.key});

  @override
  State<TiposMovimentacoesEstoquePage> createState() =>
      _TiposMovimentacoesEstoquePageState();
}

class _TiposMovimentacoesEstoquePageState
    extends State<TiposMovimentacoesEstoquePage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _tiposMovimentacoesEstoque = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarTiposMovimentacoesEstoque();
    super.initState();
  }

  Future<void> _listarTiposMovimentacoesEstoque([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .get(Uri.http(
              apiUrl,
              query != null && query != ''
                  ? '/TiposMovimentacaoEstoque/descricao/$query'
                  : '/TiposMovimentacaoEstoque'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _tiposMovimentacoesEstoque =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro(
            'Erro ao listar tipos de movimentações de estoque: ${response.statusCode}');
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

  void _abrirFormularioTipoMovimentacaoEstoque(
      {Map<String, dynamic>? tipoMovimentacaoEstoque}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TipoMovimentacaoEstoqueFormPage(
          tipoMovimentacaoEstoque: tipoMovimentacaoEstoque,
        ),
      ),
    );
    _listarTiposMovimentacoesEstoque();
  }

  void _pesquisarTiposMovimentacoesEstoque() {
    _listarTiposMovimentacoesEstoque(_pesquisaController.text);
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
        title: const Text('Tipos Movimentações Estoque'),
      ),
      drawer: const DrawerFenomenos('Tipos de Movimentações de Estoque'),
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
                    onSubmitted: (_) => _pesquisarTiposMovimentacoesEstoque(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _pesquisarTiposMovimentacoesEstoque,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tiposMovimentacoesEstoque.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            _tiposMovimentacoesEstoque[index]['descricao']),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TiposMovimentacaoDetalhesPage(
                                      tipoMovimentacao:
                                          _tiposMovimentacoesEstoque[index]),
                            ),
                          );
                          _listarTiposMovimentacoesEstoque();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioTipoMovimentacaoEstoque(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
