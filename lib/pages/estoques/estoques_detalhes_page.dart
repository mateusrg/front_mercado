import 'package:flutter/material.dart';
import 'package:front_mercado/pages/estoques/estoques_form.dart';
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
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.warehouse, color: Colors.cyan),
                        title: Text('Estoque'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.warehouse_outlined,
                          color: Colors.cyan.withValues(alpha: 0.5),
                        ),
                        title: Text(widget.estoque['descricaoEstoque']),
                        subtitle: Text(
                            widget.estoque['descricaoTipoEstoque'] ?? 'N/A'),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.shopping_bag, color: Colors.green),
                        title: Text('Produtos no Estoque'),
                      ),
                      carregandoProdutos
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0;
                                    i <
                                        (produtos.length > 3
                                            ? 3
                                            : produtos.length);
                                    i++)
                                  ListTile(
                                    leading: Icon(
                                      Icons.shopping_bag_outlined,
                                      color:
                                          Colors.green.withValues(alpha: 0.5),
                                    ),
                                    title: Text(produtos[i]['produto']),
                                    trailing: Text(
                                        '${produtos[i]['quantidade']} un.'),
                                  ),
                                if (produtos.length > 3)
                                  ListTile(
                                    leading: Icon(
                                      Icons.add,
                                      color: Colors.grey.withValues(alpha: 0.5),
                                    ),
                                    title: const Text('E mais...'),
                                  ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(
                          Icons.history,
                          color: Colors.yellow,
                        ),
                        title: Text('Movimentações Recentes'),
                      ),
                      carregandoMovimentacoes
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
                                  ListTile(
                                    leading: Icon(
                                      Icons.history_outlined,
                                      color:
                                          Colors.yellow.withValues(alpha: 0.5),
                                    ),
                                    title: Text(movimentacoesRecentes[i]
                                        ['descricaoProduto']),
                                    subtitle: Text(
                                        '${movimentacoesRecentes[i]['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(movimentacoesRecentes[i]['dataHora']))}'),
                                    trailing: Text(
                                        '${movimentacoesRecentes[i]['quantidade'].abs()} un.'),
                                  ),
                                if (movimentacoesRecentes.length > 3)
                                  ListTile(
                                    leading: Icon(
                                      Icons.add,
                                      color: Colors.grey.withValues(alpha: 0.5),
                                    ),
                                    title: const Text('E mais...'),
                                  ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () async {
          final resultado = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EstoquesFormPage(estoque: widget.estoque),
            ),
          );

          if (resultado == true) {
            setState(() {
              carregarProdutosEMovimentacoesRecentes();
            });
          }
        },
      ),
    );
  }
}
