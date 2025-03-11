import 'package:flutter/material.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_transferencia.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_vendas.dart';
import 'package:front_mercado/pages/compras/compras_form.dart'; // Importe a página de cadastro de compras
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import 'movimentacao_estoque_detalhes.dart';

class MovimentacoesEstoquePage extends StatefulWidget {
  const MovimentacoesEstoquePage({super.key});

  @override
  State<MovimentacoesEstoquePage> createState() =>
      _MovimentacoesEstoquePageState();
}

class _MovimentacoesEstoquePageState extends State<MovimentacoesEstoquePage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _movimentacoes = [];
  bool _carregando = false;

  @override
  void initState() {
    _listarMovimentacoes();
    super.initState();
  }

  Future<void> _listarMovimentacoes() async {
    setState(() {
      _carregando = true;
    });

    try {
      final response =
          await http.get(Uri.http(apiUrl, '/MovimentacoesEstoque/view'));
      if (response.statusCode == 200) {
        setState(() {
          _movimentacoes =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _mostrarErro('Erro ao listar movimentações: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _abrirFormularioVenda() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VendaPage(
          onSave: (venda) async {
            await _adicionarMovimentacao(venda);
          },
        ),
      ),
    );
  }

  void _abrirFormularioTransferencia() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransferenciaEstoquePage(
          onSave: (transferencia) async {
            await _adicionarMovimentacao(transferencia);
          },
        ),
      ),
    );
  }

  void _abrirFormularioCompras() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompraFormPage(
          onSave: (compra) async {
            await _adicionarMovimentacao(compra);
          },
        ),
      ),
    );
  }

  Future<void> _adicionarMovimentacao(Map<String, dynamic> movimentacao) async {
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/MovimentacoesEstoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(movimentacao),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarMovimentacoes();
      } else {
        _mostrarErro('Erro ao adicionar movimentação: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
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
                    itemCount: _movimentacoes.length,
                    itemBuilder: (context, index) {
                      final movimentacao = _movimentacoes[index];
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MovimentacaoDetalhesPage(
                                movimentacao: movimentacao,
                              ),
                            ),
                          );
                        },
                        title: Text(movimentacao['descricaoProduto']),
                        subtitle: Text('${movimentacao['descricaoEstoque']}'),
                        leading: Text(
                          '${movimentacao['quantidade'] >= 0 ? '+' : '-'}${movimentacao['quantidade'].abs()}',
                          style: TextStyle(
                            color: movimentacao['quantidade'] >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        trailing: Text(
                            '${movimentacao['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.parse(movimentacao['dataHora']))}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.red,
        activeForegroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.shopping_cart),
            backgroundColor: const Color.fromARGB(255, 0, 156, 59),
            label: 'Vender',
            onTap: _abrirFormularioVenda,
          ),
          SpeedDialChild(
            child: const Icon(Icons.swap_horiz),
            backgroundColor: const Color.fromARGB(255, 240, 222, 57),
            label: 'Transferir de Estoque',
            onTap: _abrirFormularioTransferencia,
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_shopping_cart),
            backgroundColor: const Color.fromARGB(255, 0, 39, 118),
            label: 'Cadastrar Compra',
            onTap: _abrirFormularioCompras,
          ),
        ],
      ),
    );
  }
}
