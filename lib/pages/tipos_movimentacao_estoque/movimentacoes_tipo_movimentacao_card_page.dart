import 'package:flutter/material.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacao_estoque_detalhes_page.dart';
import 'package:intl/intl.dart';

class MovimentacoesDoTipoMovimentacaoPage extends StatelessWidget {
  const MovimentacoesDoTipoMovimentacaoPage({
    super.key,
    required this.movimentacoes,
  });
  final List<dynamic> movimentacoes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloMovimentacoesDoTipoEstoque',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.green,
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
            for (int i = 0; i < movimentacoes.length; i++)
              Hero(
                tag: 'listTileMovimentacoesDoTipoEstoque$i',
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
                      color: Colors.green.withAlpha(128),
                    ),
                    title: Text(movimentacoes[i]['descricaoProduto']),
                    subtitle: Text(
                        '${movimentacoes[i]['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(movimentacoes[i]['dataHora']))}'),
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
