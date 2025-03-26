import 'package:flutter/material.dart';
import 'package:front_mercado/pages/estoques/estoques_detalhes_page.dart';

class EstoquesDoTipoEstoquePage extends StatelessWidget {
  const EstoquesDoTipoEstoquePage({
    super.key,
    required this.estoques,
  });
  final List<dynamic> estoques;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloEstoqueDoTipoEstoque',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.history,
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
                tag: 'listTileComprasDoTipoEstoque$i',
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EstoqueDetalhesPage(estoque: estoques[i]),
                        ),
                      );
                    },
                    leading: Icon(
                      Icons.history_outlined,
                      color: Colors.green.withValues(alpha: 0.5),
                    ),
                    title: Text(estoques[i]['descricaoEstoque']),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
