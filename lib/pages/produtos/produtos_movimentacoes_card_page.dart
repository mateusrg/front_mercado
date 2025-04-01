import 'package:flutter/material.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacao_estoque_detalhes_page.dart';
import 'package:intl/intl.dart';

class MovimentacoesRecentesDoProdutoPage extends StatelessWidget {
  const MovimentacoesRecentesDoProdutoPage({
    super.key,
    required this.movimentacoes,
  });
  final List<dynamic> movimentacoes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloMovimentacoesRecentesDoProduto',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.yellow,
              ),
              title: Text(
                'Movimentações',
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
            if (movimentacoes.isEmpty)
              Center(
                child: Hero(
                  tag: 'nenhumaMovimentacao',
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Icon(
                        Icons.remove,
                        color: Colors.grey.withAlpha(128),
                      ),
                      title: const Text(
                        'Nenhuma movimentação',
                      ),
                    ),
                  ),
                ),
              ),
            for (int i = 0; i < movimentacoes.length; i++)
              Hero(
                tag: 'listTileMovimentacoesRecentesDoProduto$i',
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MovimentacaoDetalhesPage(
                              movimentacao: movimentacoes[i]),
                        ),
                      );
                    },
                    leading: Icon(
                      Icons.history_outlined,
                      color: Colors.yellow.withAlpha(128),
                    ),
                    title:
                        Text(movimentacoes[i]['descricaoMovimentacaoEstoque']),
                    subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                        .format(DateTime.parse(movimentacoes[i]['dataHora']))),
                    trailing:
                        Text('${movimentacoes[i]['quantidade'].abs()} un.'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
