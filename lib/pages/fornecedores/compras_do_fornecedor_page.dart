import 'package:flutter/material.dart';
import 'package:front_mercado/pages/compras/compras_detalhes_page.dart';
import 'package:intl/intl.dart';

class ComprasDoFornecedorPage extends StatelessWidget {
  const ComprasDoFornecedorPage({
    super.key,
    required this.compras,
  });
  final List<dynamic> compras;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloComprasDoFornecedor',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.shopping_cart,
                color: Colors.green,
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
            if (compras.isEmpty)
              Center(
                child: Hero(
                  tag: 'nenhumaCompra',
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Icon(
                        Icons.remove,
                        color: Colors.grey.withAlpha(128),
                      ),
                      title: const Text(
                        'Nenhuma compra',
                      ),
                    ),
                  ),
                ),
              ),
            for (int i = 0; i < compras.length; i++)
              Hero(
                tag: 'listTileComprasDoFornecedor$i',
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
                      color: Colors.green.withValues(alpha: 0.5),
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
