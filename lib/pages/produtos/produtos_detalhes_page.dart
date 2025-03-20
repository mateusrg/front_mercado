import 'package:flutter/material.dart';
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
  List<dynamic> estoques = [];
  List<dynamic> movimentacoesRecentes = [];
  List<dynamic> compras = [];
  bool carregandoEstoques = true;
  bool carregandoMovimentacoes = true;
  bool carregandoCompras = true;

  @override
  void initState() {
    super.initState();
    carregarEstoques();
    carregarMovimentacoesRecentes();
    carregarCompras();
  }

  Future<void> carregarEstoques() async {
    final response = await http.get(Uri.http(
        Params.ipApi, '/produtos/estoques/${widget.produto['idProduto']}'));
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
    final response = await http.get(Uri.http(Params.ipApi,
        '/produtos/movimentacoesRecentes/${widget.produto['idProduto']}'));
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
    final response = await http.get(Uri.http(
        Params.ipApi, '/produtos/compras/${widget.produto['idProduto']}'));
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('Produto'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descrição: ${widget.produto['descricao']}'),
                      Text('Código de Barras: ${widget.produto['codBarras']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.warehouse),
                  title: const Text('Estoques'),
                  subtitle: carregandoEstoques
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var estoque in estoques)
                              Text(
                                  '${estoque['descricaoEstoque']}: ${estoque['quantidade']} unidades'),
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
                                i < (movimentacoesRecentes.length > 5
                                    ? 5
                                    : movimentacoesRecentes.length);
                                i++)
                              Text(
                                  '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(movimentacoesRecentes[i]['dataHora']))}: ${movimentacoesRecentes[i]['quantidade']} unidades (${movimentacoesRecentes[i]['descricaoMovimentacaoEstoque']})'),
                            if (movimentacoesRecentes.length > 5)
                              const Text('E mais...'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Compras'),
                  subtitle: carregandoCompras
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0;
                                i < (compras.length > 5 ? 5 : compras.length);
                                i++)
                              Text(
                                  '${DateFormat('dd/MM/yyyy').format(DateTime.parse(compras[i]['data']))}: ${compras[i]['quantidade']} unidades de ${compras[i]['descricaoProduto']}'),
                            if (compras.length > 5) const Text('E mais...'),
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
