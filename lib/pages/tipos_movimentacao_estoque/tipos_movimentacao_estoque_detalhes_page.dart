import 'package:flutter/material.dart';
import 'package:front_mercado/pages/tipos_movimentacao_estoque/movimentacoes_tipo_movimentacao_card_page.dart';
import 'package:front_mercado/pages/tipos_movimentacao_estoque/tipos_movimentacao_estoque_card_page.dart';
import 'package:front_mercado/pages/tipos_movimentacao_estoque/tipos_movimentacao_estoque_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_mercado/params.dart';
import 'package:intl/intl.dart';

class TiposMovimentacaoDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> tipoMovimentacao;

  const TiposMovimentacaoDetalhesPage(
      {super.key, required this.tipoMovimentacao});

  @override
  State<TiposMovimentacaoDetalhesPage> createState() =>
      _TiposMovimentacaoDetalhesPageState();
}

class _TiposMovimentacaoDetalhesPageState
    extends State<TiposMovimentacaoDetalhesPage> {
  static const String apiUrl = Params.apiUrl;
  List<dynamic> movimentacoes = [];
  bool carregandoMovimentacoes = true;

  @override
  void initState() {
    super.initState();
    carregarMovimentacoes();
  }

  Future<void> carregarMovimentacoes() async {
    final response = await http.get(Uri.http(apiUrl,
        '/TiposMovimentacaoEstoque/movimentacoes/${widget.tipoMovimentacao['idTipoMovimentacaoEstoque']}'));
    if (response.statusCode == 200) {
      setState(() {
        movimentacoes = json.decode(response.body);
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
        title: const Text('Detalhes do Tipo de Movimentação'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tipoRecebido = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TipoMovimentacaoEstoqueFormPage(
                tipoMovimentacaoEstoque: widget.tipoMovimentacao,
              ),
            ),
          );

          if (tipoRecebido == null) return;

          setState(() {
            widget.tipoMovimentacao['descricao'] = tipoRecebido['descricao'];
          });
        },
        child: const Icon(Icons.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TiposMovimentacaoEstoqueCardPage(
                          tipoMovimentacaoEstoque: widget.tipoMovimentacao),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloTiposMovimentacaoEstoqueCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.move_down_rounded,
                              color: Colors.cyan,
                            ),
                            title: Text('Tipo'),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'listTileTiposMovimentacaoEstoqueCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.move_down_rounded,
                              color: Colors.cyan.withAlpha(128),
                            ),
                            title: Text(widget.tipoMovimentacao['descricao']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MovimentacoesDoTipoMovimentacaoPage(
                          movimentacoes: movimentacoes),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloMovimentacoesDoTipoEstoque',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.history,
                              color: Colors.green,
                            ),
                            title: Text('Movimentações desse Tipo'),
                          ),
                        ),
                      ),
                      carregandoMovimentacoes
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                for (int i = 0;
                                    i <
                                        (movimentacoes.length > 3
                                            ? 3
                                            : movimentacoes.length);
                                    i++)
                                  Hero(
                                    tag: 'listTileMovimentacoesDoTipoEstoque$i',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        leading: Icon(Icons.history_outlined,
                                            color: Colors.green
                                                .withValues(alpha: 0.5)),
                                        title: Text(movimentacoes[i]
                                            ['descricaoProduto']),
                                        subtitle: Text(
                                            '${movimentacoes[i]['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(movimentacoes[i]['dataHora']))}'),
                                        trailing: Text(
                                            '${movimentacoes[i]['quantidade']} un.'),
                                      ),
                                    ),
                                  ),
                                if (movimentacoes.length > 3)
                                  ListTile(
                                    leading: Icon(Icons.add,
                                        color:
                                            Colors.grey.withValues(alpha: 0.5)),
                                    title: const Text('E mais...'),
                                  ),
                              ],
                            ),
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
