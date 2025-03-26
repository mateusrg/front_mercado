import 'package:flutter/material.dart';

class ProdutosDetalhesCardPage extends StatelessWidget {
  const ProdutosDetalhesCardPage({
    super.key,
    required this.produto,
  });

  final Map<String, dynamic> produto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloProdutosDetalhesCard',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.shopping_bag,
                color: Colors.cyan,
              ),
              title: Text(
                'Produto',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: Hero(
        tag: 'listTileProdutosDetalhesCard',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              Icons.shopping_bag_outlined,
              color: Colors.cyan.withAlpha(128),
            ),
            title: Text(produto['descricao']),
            subtitle: Text(produto['codBarras']),
          ),
        ),
      ),
    );
  }
}
