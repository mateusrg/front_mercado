import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_form.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class MovimentacoesEstoquePage extends StatefulWidget {
  const MovimentacoesEstoquePage({super.key});

  @override
  State<MovimentacoesEstoquePage> createState() => _MovimentacoesEstoquePageState();
}

class _MovimentacoesEstoquePageState extends State<MovimentacoesEstoquePage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _movimentacoesEstoque = [];
  bool _carregando = false;

  @override
  void initState() {
    _listarMovimentacoesEstoque();
    super.initState();
  }

  Future<void> _listarMovimentacoesEstoque() async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .get(Uri.http(apiUrl, '/MovimentacoesEstoque'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _movimentacoesEstoque =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar movimentações de estoque: ${response.statusCode}');
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

  Future<void> _adicionarMovimentacaoEstoque(Map<String, dynamic> movimentacaoEstoque) async {
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/MovimentacoesEstoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(movimentacaoEstoque),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarMovimentacoesEstoque();
      } else {
        _mostrarErro('Erro ao adicionar movimentação de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioMovimentacaoEstoque() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovimentacaoEstoqueFormPage(
          onSave: (movimentacaoEstoque) async {
            await _adicionarMovimentacaoEstoque(movimentacaoEstoque);
          },
        ),
      ),
    );
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
        title: const Text('Movimentações de Estoque'),
      ),
      drawer: const DrawerFenomenos(),
      body: Column(
        children: [
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _movimentacoesEstoque.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Produto: ${_movimentacoesEstoque[index]['produto']}'),
                        subtitle: Text('Quantidade: ${_movimentacoesEstoque[index]['quantidade']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioMovimentacaoEstoque,
        child: const Icon(Icons.add),
      ),
    );
  }
}
