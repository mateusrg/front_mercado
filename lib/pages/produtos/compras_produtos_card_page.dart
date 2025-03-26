import 'package:flutter/material.dart';
import 'package:front_mercado/pages/compras/compras_detalhes_page.dart';
import 'package:intl/intl.dart';

class ComprasDoProdutoPage extends StatelessWidget {
  const ComprasDoProdutoPage({
    super.key,
    required this.compras,
  });
  final List<dynamic> compras;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloComprasDoProduto',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.shopping_cart,
                color: Colors.blue,
              ),
              title: Text(
                'Compras',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < compras.length; i++)
              Hero(
                tag: 'listTileComprasDoProduto$i',
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CompraDetalhesPage(compra: compras[i]),
                        ),
                      );
                    },
                    leading: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.blue.withAlpha(128),
                    ),
                    title: Text(compras[i]['descricaoProduto']),
                    subtitle: Text(DateFormat('dd/MM/yyyy, HH:mm')
                        .format(DateTime.parse(compras[i]['data']))),
                    trailing: Text('${compras[i]['quantidade']} un.'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
