import 'package:flutter/material.dart';
import 'package:front_mercado/pages/produtos/produtos_form_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:front_mercado/params.dart';

class ProdutosDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> produto;

  const ProdutosDetalhesPage({super.key, required this.produto});

  @override
  State<ProdutosDetalhesPage> createState() => _ProdutosDetalhesPageState();
}

class _ProdutosDetalhesPageState extends State<ProdutosDetalhesPage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<dynamic> estoques = [];
  List<dynamic> movimentacoesRecentes = [];
  List<dynamic> compras = [];
  bool carregandoEstoques = true;
  bool carregandoMovimentacoes = true;
  bool carregandoCompras = true;

  @override
  void initState() {
    super.initState();
    carregarDetalhes();
  }

  Future<void> carregarDetalhes() async {
    await carregarEstoques();
    await carregarMovimentacoesRecentes();
    await carregarCompras();
  }

  Future<void> carregarEstoques() async {
    final response = await http.get(Uri.http(
        apiUrl, '/Produtos/quantPorEstoque/${widget.produto['idProduto']}'));
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

  Future<void> carregarMovimentacoesRecentes() async {
    final response = await http.get(Uri.http(apiUrl,
        '/Produtos/movimentacoesRecentes/${widget.produto['idProduto']}'));
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

  Future<void> carregarCompras() async {
    final response = await http
        .post(
          Uri.http(apiUrl, '/Compras/tudo'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'idProduto': widget.produto['idProduto']}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      setState(() {
        compras = json.decode(response.body);
        carregandoCompras = false;
      });
    } else {
      setState(() {
        carregandoCompras = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final produtoRecebido = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProdutosFormPage(
                produto: widget.produto,
              ),
            ),
          );

          if (produtoRecebido == null) return;

          setState(() {
            widget.produto['codBarras'] = produtoRecebido['codBarras'];
            widget.produto['descricao'] = produtoRecebido['descricao'];
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
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(
                          Icons.shopping_bag,
                          color: Colors.cyan,
                        ),
                        title: Text('Produto'),
                      ),
                      ListTile(
                        leading: Icon(Icons.shopping_bag_outlined,
                            color: Colors.cyan.withValues(alpha: 0.5)),
                        title: Text(widget.produto['descricao']),
                        subtitle: Text(widget.produto['codBarras']),
                      ),
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
                        leading: Icon(Icons.warehouse, color: Colors.green),
                        title: Text('Estoques'),
                      ),
                      carregandoEstoques
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                for (var estoque in estoques)
                                  ListTile(
                                    leading: Icon(Icons.warehouse_outlined,
                                        color: Colors.green
                                            .withValues(alpha: 0.5)),
                                    title: Text(estoque['estoque']),
                                    trailing:
                                        Text('${estoque['quantidade']} un.'),
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
                        leading: Icon(Icons.history, color: Colors.yellow),
                        title: Text('Movimentações Recentes'),
                      ),
                      carregandoMovimentacoes
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                for (int i = 0;
                                    i <
                                        (movimentacoesRecentes.length > 3
                                            ? 3
                                            : movimentacoesRecentes.length);
                                    i++)
                                  ListTile(
                                    leading: Icon(Icons.history_outlined,
                                        color: Colors.yellow
                                            .withValues(alpha: 0.5)),
                                    title: Text(movimentacoesRecentes[i]
                                        ['descricaoMovimentacaoEstoque']),
                                    subtitle: Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(
                                            DateTime.parse(
                                                movimentacoesRecentes[i]
                                                    ['dataHora']))),
                                    trailing: Text(
                                        '${movimentacoesRecentes[i]['quantidade'].abs()} un.'),
                                  ),
                                if (movimentacoesRecentes.length > 3)
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
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.shopping_cart, color: Colors.blue),
                        title: Text('Compras'),
                      ),
                      carregandoCompras
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0;
                                    i <
                                        (compras.length > 3
                                            ? 3
                                            : compras.length);
                                    i++)
                                  ListTile(
                                    leading: Icon(Icons.shopping_cart_outlined,
                                        color:
                                            Colors.blue.withValues(alpha: 0.5)),
                                    title: Text(compras[i]['descricaoProduto']),
                                    subtitle: Text(DateFormat('dd/MM/yyyy')
                                        .format(DateTime.parse(
                                            compras[i]['data']))),
                                    trailing:
                                        Text('${compras[i]['quantidade']} un.'),
                                  ),
                                if (compras.length > 3)
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
