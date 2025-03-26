import 'package:flutter/material.dart';
import 'package:front_mercado/pages/tipos_estoque/tipo_estoque_estoques_page.dart';
import 'package:front_mercado/pages/tipos_estoque/tipos_estoque_card_page.dart';
import 'package:front_mercado/pages/tipos_estoque/tipos_estoque_form_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_mercado/params.dart';

class TiposEstoqueDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> tipoEstoque;

  const TiposEstoqueDetalhesPage({super.key, required this.tipoEstoque});

  @override
  State<TiposEstoqueDetalhesPage> createState() =>
      _TiposEstoqueDetalhesPageState();
}

class _TiposEstoqueDetalhesPageState extends State<TiposEstoqueDetalhesPage> {
  static const String apiUrl = Params.apiUrl;
  List<dynamic> estoques = [];
  bool carregandoEstoques = true;

  @override
  void initState() {
    super.initState();
    carregarEstoques();
  }

  Future<void> carregarEstoques() async {
    final response = await http.get(Uri.http(apiUrl,
        '/Estoques/tipoEstoque/${widget.tipoEstoque['idTipoEstoque']}'));
    if (response.statusCode == 200) {
      setState(() {
        estoques = json.decode(response.body);
        carregandoEstoques = false;
      });
    } else {
      setState(() {
        carregandoEstoques = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Tipo de Estoque'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tipoRecebido = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TipoEstoqueFormPage(
                tipoEstoque: widget.tipoEstoque,
              ),
            ),
          );

          if (tipoRecebido == null) return;

          setState(() {
            widget.tipoEstoque['descricao'] = tipoRecebido['descricao'];
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
                      builder: (context) =>
                          TiposEstoqueCardPage(tipoEstoque: widget.tipoEstoque),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloTiposEstoqueCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.inventory_rounded,
                              color: Colors.cyan,
                            ),
                            title: Text('Tipo de Estoque'),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'listTileTiposEstoqueCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.inventory_outlined,
                              color: Colors.cyan.withAlpha(128),
                            ),
                            title: Text(widget.tipoEstoque['descricao']),
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
                      builder: (context) =>
                          EstoquesDoTipoEstoquePage(estoques: estoques),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloEstoqueDoTipoEstoque',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.history,
                              color: Colors.green,
                            ),
                            title: Text('Estoques'),
                          ),
                        ),
                      ),
                      carregandoEstoques
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                for (int i = 0;
                                    i <
                                        (estoques.length > 3
                                            ? 3
                                            : estoques.length);
                                    i++)
                                  Hero(
                                    tag: 'listTileComprasDoTipoEstoque$i',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        leading: Icon(Icons.history_outlined,
                                            color: Colors.green
                                                .withValues(alpha: 0.5)),
                                        title: Text(
                                            estoques[i]['descricaoEstoque']),
                                      ),
                                    ),
                                  ),
                                if (estoques.length > 3)
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
