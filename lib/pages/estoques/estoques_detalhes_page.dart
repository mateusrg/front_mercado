import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class EstoqueDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> estoque;

  const EstoqueDetalhesPage({super.key, required this.estoque});

  @override
  State<EstoqueDetalhesPage> createState() => _EstoqueDetalhesPageState();
}

const String apiUrl = '${Params.ipApi}:5277';

class _EstoqueDetalhesPageState extends State<EstoqueDetalhesPage> {
  List<dynamic> produtos = [];
  List<dynamic> movimentacoesRecentes = [];
  bool carregandoProdutos = true;
  bool carregandoMovimentacoes = true;

  @override
  void initState() {
    super.initState();
    carregarProdutosEMovimentacoesRecentes();
  }

  carregarProdutosEMovimentacoesRecentes() async {
    await carregarProdutos();
    await carregarMovimentacoesRecentes();
  }

  Future<void> carregarProdutos() async {
    final response = await http.get(Uri.http(apiUrl,
        '/Estoques/quantidadeProdutosNoEstoque/${widget.estoque['idEstoque']}'));
    if (response.statusCode == 200) {
      setState(() {
        produtos = json.decode(response.body);
        carregandoProdutos = false;
      });
    } else {
      setState(() {
        carregandoProdutos = false;
      });
    }
  }

  Future<void> carregarMovimentacoesRecentes() async {
    final response = await http.get(Uri.http(apiUrl,
        '/Estoques/movimentacoesRecentes/${widget.estoque['idEstoque']}'));
    if (response.statusCode == 200) {
      setState(() {
        movimentacoesRecentes = json.decode(response.body);
        carregandoMovimentacoes = false;
      });
    } else {
      setState(() {
        carregandoMovimentacoes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Estoque'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.warehouse),
                  title: const Text('Estoque'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descrição: ${widget.estoque['descricaoEstoque']}'),
                      Text(
                          'Tipo: ${widget.estoque['descricaoTipoEstoque'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('Produtos no Estoque'),
                  subtitle: carregandoProdutos
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0;
                                i < (produtos.length > 5 ? 5 : produtos.length);
                                i++)
                              Text(
                                  '${produtos[i]['produto']}: ${produtos[i]['quantidade']} un.'),
                            if (produtos.length > 5) const Text('E mais...'),
                            // falta testar com um estoque que tenha mais de 5 produtos cadastrados
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Movimentações Recentes'),
                  subtitle: carregandoMovimentacoes
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0;
                                i <
                                    (movimentacoesRecentes.length > 3
                                        ? 3
                                        : movimentacoesRecentes.length);
                                i++)
                              Text(
                                  '${DateFormat('dd/MM/yy hh,mm').format(DateTime.parse(movimentacoesRecentes[i]['dataHora']))}: ${movimentacoesRecentes[i]['quantidade'].abs()} ${movimentacoesRecentes[i]['descricaoProduto']} (${movimentacoesRecentes[i]['descricaoMovimentacaoEstoque']})'),
                            if (movimentacoesRecentes.length > 3)
                              const Text('E mais...'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
