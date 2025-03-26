import 'package:flutter/material.dart';
import 'package:front_mercado/pages/compras/compras_detalhes_data_page.dart';
import 'package:front_mercado/pages/fornecedores/fornecedores_detalhes_page.dart';
import 'package:front_mercado/pages/produtos/produtos_detalhes_page.dart';
import 'package:intl/intl.dart';

class CompraDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> compra;

  const CompraDetalhesPage({super.key, required this.compra});

  @override
  Widget build(BuildContext context) {
    final data = DateTime.parse(compra['data']);
    final dataFormatada = DateFormat('dd/MM/yyyy').format(data);
    final horarioFormatado = DateFormat('HH:mm').format(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ComprasDetalhesDataPage(compra: compra),
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Hero(
                      tag: 'comprasDetalhesDataTitulo',
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Icon(Icons.calendar_month_rounded,
                              color: Colors.cyan),
                          title: Text('Data'),
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'listTileCompraDetalhesData',
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.cyan.withValues(alpha: 0.5),
                          ),
                          title: Text(dataFormatada),
                          subtitle: Text(horarioFormatado),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: GestureDetector(
                onTap: () async {
                  final produto = {
                    'idProduto': compra['idProduto'],
                    'codBarras': compra['codBarrasProduto'],
                    'descricao': compra['descricaoProduto']
                  };

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProdutosDetalhesPage(produto: produto),
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Hero(
                      tag: 'tituloProdutosDetalhesCard',
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Icon(
                            Icons.shopping_bag,
                            color: Colors.green,
                          ),
                          title: Text('Produto'),
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'listTileProdutosDetalhesCard',
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.green.withValues(alpha: 0.5),
                          ),
                          title: Text(compra['descricaoProduto']),
                          subtitle: Text(compra['codBarrasProduto']),
                          trailing: Text('${compra['quantidade']} un.'),
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
                onTap: () async {
                  final fornecedor = {
                    'idFornecedor': compra['idFornecedor'],
                    'cnpj': compra['cnpjFornecedor'],
                    'nome': compra['nomeFornecedor']
                  };

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          FornecedorDetalhesPage(fornecedor: fornecedor),
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Hero(
                      tag: 'tituloFornecedoresDetalhesCard',
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Icon(
                            Icons.business,
                            color: Colors.yellow,
                          ),
                          title: Text('Fornecedor'),
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'listTileFornecedoresDetalhesCard',
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Icon(
                            Icons.business_outlined,
                            color: Colors.yellow.withValues(alpha: 0.5),
                          ),
                          title: Text(compra['nomeFornecedor']),
                          subtitle: Text(compra['cnpjFornecedor']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
