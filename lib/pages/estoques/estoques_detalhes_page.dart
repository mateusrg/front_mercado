import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:front_mercado/pages/estoques/estoque_detalhes_card_page.dart';
import 'package:front_mercado/pages/estoques/estoques_form.dart';
import 'package:front_mercado/pages/estoques/movimentacoes_recentes_do_estoque_page.dart';
import 'package:front_mercado/pages/estoques/produtos_no_estoque_page.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_descarte.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_transferencia.dart';
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

const String apiUrl = Params.apiUrl;

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
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EstoqueDetalhesCardPage(estoque: widget.estoque),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloEstoqueDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.warehouse,
                              color: Colors.cyan,
                            ),
                            title: Text('Estoque'),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'listTileEstoqueDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.warehouse_outlined,
                              color: Colors.cyan.withAlpha(128),
                            ),
                            title: Text(widget.estoque['descricaoEstoque']),
                            subtitle: Text(
                                widget.estoque['descricaoTipoEstoque'] ??
                                    'N/A'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProdutosNoEstoquePage(produtos: produtos),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'produtosNoEstoqueTitulo',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading:
                                Icon(Icons.shopping_bag, color: Colors.green),
                            title: Text('Produtos no Estoque'),
                          ),
                        ),
                      ),
                      carregandoProdutos
                          ? const Center(child: CircularProgressIndicator())
                          : produtos.isEmpty
                              ? Center(
                                  child: Hero(
                                    tag: 'nenhumProduto',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.remove,
                                          color: Colors.grey.withAlpha(128),
                                        ),
                                        title: const Text(
                                          'Nenhum produto',
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0;
                                        i <
                                            (produtos.length > 3
                                                ? 3
                                                : produtos.length);
                                        i++)
                                      Hero(
                                        tag: 'listTileProdutosNoEstoque$i',
                                        child: Material(
                                          color: Colors.transparent,
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.shopping_bag_outlined,
                                              color:
                                                  Colors.green.withAlpha(128),
                                            ),
                                            title: Text(produtos[i]['produto']),
                                            trailing: Text(
                                                '${produtos[i]['quantidade']} un.'),
                                          ),
                                        ),
                                      ),
                                    if (produtos.length > 3)
                                      ListTile(
                                        leading: Icon(
                                          Icons.add,
                                          color: Colors.grey.withAlpha(128),
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MovimentacoesRecentesDoEstoquePage(
                                movimentacoes: movimentacoesRecentes),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloMovimentacoesRecentesDoEstoque',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.history,
                              color: Colors.yellow,
                            ),
                            title: Text('Movimentações Recentes'),
                          ),
                        ),
                      ),
                      carregandoMovimentacoes
                          ? const Center(child: CircularProgressIndicator())
                          : movimentacoesRecentes.isEmpty
                              ? Center(
                                  child: Hero(
                                    tag: 'nenhumaMovimentacao',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.remove,
                                          color: Colors.grey.withAlpha(128),
                                        ),
                                        title: const Text(
                                          'Nenhuma movimentação',
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (int i = 0;
                                            i <
                                                (movimentacoesRecentes.length >
                                                        3
                                                    ? 3
                                                    : movimentacoesRecentes
                                                        .length);
                                            i++)
                                          Hero(
                                            tag:
                                                'listTileMovimentacoesRecentesDoEstoque$i',
                                            child: Material(
                                              color: Colors.transparent,
                                              child: ListTile(
                                                leading: Icon(
                                                  Icons.history_outlined,
                                                  color: Colors.yellow
                                                      .withAlpha(128),
                                                ),
                                                title: Text(
                                                    movimentacoesRecentes[i]
                                                        ['descricaoProduto']),
                                                subtitle: Text(
                                                    '${movimentacoesRecentes[i]['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(movimentacoesRecentes[i]['dataHora']))}'),
                                                trailing: Text(
                                                    '${movimentacoesRecentes[i]['quantidade'].abs()} un.'),
                                              ),
                                            ),
                                          ),
                                        if (movimentacoesRecentes.length > 3)
                                          ListTile(
                                            leading: Icon(
                                              Icons.add,
                                              color: Colors.grey.withAlpha(128),
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
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.red,
        activeForegroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.delete),
            backgroundColor: const Color.fromARGB(255, 0, 156, 59),
            label: 'Descartar',
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DescartePage(estoque: widget.estoque),
                ),
              );
              setState(() {
                carregandoMovimentacoes = true;
                carregandoProdutos = true;
              });
              await carregarProdutosEMovimentacoesRecentes();
              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.swap_horiz),
            backgroundColor: const Color.fromARGB(255, 240, 222, 57),
            label: 'Transferir Estoque',
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      TransferenciaEstoquePage(estoque: widget.estoque),
                ),
              );
              setState(() {
                carregandoMovimentacoes = true;
                carregandoProdutos = true;
              });
              await carregarProdutosEMovimentacoesRecentes();
              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            backgroundColor: const Color.fromARGB(255, 0, 39, 118),
            label: 'Editar',
            onTap: () async {
              final resultado = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EstoquesFormPage(estoque: widget.estoque),
                ),
              );

              if (resultado != null) {
                setState(() {
                  widget.estoque['descricaoEstoque'] = resultado['estoque'];
                  widget.estoque['idTipoEstoque'] = resultado['idTipoEstoque'];
                  widget.estoque['descricaoTipoEstoque'] =
                      resultado['tipoEstoque'];
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
