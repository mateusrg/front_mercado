import 'package:flutter/material.dart';
import 'package:front_mercado/pages/estoques/estoques_detalhes_page.dart';

class EstoquesDoProdutoPage extends StatelessWidget {
  const EstoquesDoProdutoPage({
    super.key,
    required this.estoques,
  });
  final List<dynamic> estoques;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloEstoqueDoProduto',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.warehouse,
                color: Colors.green,
              ),
              title: Text(
                'Estoques',
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
            for (int i = 0; i < estoques.length; i++)
              Hero(
                tag: 'listTileComprasDoFornecedor$i',
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      final estoque = {
                        'idEstoque': estoques[i]['idEstoque'],
                        'idTipoEstoque': estoques[i]['idTipoEstoque'],
                        'descricaoEstoque': estoques[i]['estoque'],
                        'descricaoTipoEstoque': estoques[i]['tipoEstoque']
                      };

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EstoqueDetalhesPage(estoque: estoque),
                        ),
                      );
                    },
                    leading: Icon(
                      Icons.warehouse_outlined,
                      color: Colors.green.withValues(alpha: 0.5),
                    ),
                    title: Text(estoques[i]['estoque']),
                    trailing: Text('${estoques[i]['quantidade']} un.'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
