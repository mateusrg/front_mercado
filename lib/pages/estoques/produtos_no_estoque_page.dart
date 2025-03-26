import 'package:flutter/material.dart';
import 'package:front_mercado/pages/produtos/produtos_detalhes_page.dart';

class ProdutosNoEstoquePage extends StatelessWidget {
  const ProdutosNoEstoquePage({super.key, required this.produtos});
  final List<dynamic> produtos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'produtosNoEstoqueTitulo',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.green),
              title: Text(
                'Produtos no Estoque',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < produtos.length; i++)
              Hero(
                tag: 'listTileProdutosNoEstoque$i',
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      final produto = {
                        'idProduto': produtos[i]['idProduto'],
                        'descricao': produtos[i]['produto'],
                        'codBarras': produtos[i]['codBarras']
                      };
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProdutosDetalhesPage(produto: produto),
                        ),
                      );
                    },
                    leading: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.green.withValues(alpha: 0.5),
                    ),
                    title: Text(produtos[i]['produto']),
                    trailing: Text('${produtos[i]['quantidade']} un.'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
