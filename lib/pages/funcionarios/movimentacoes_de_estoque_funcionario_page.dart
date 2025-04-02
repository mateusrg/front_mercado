import 'package:flutter/material.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacao_estoque_detalhes_page.dart';
import 'package:intl/intl.dart';

class MovimentacoesFuncionarioPage extends StatelessWidget {
  const MovimentacoesFuncionarioPage({
    super.key,
    required this.movimentacoes,
    required this.funcionario,
  });

  final List<dynamic> movimentacoes;
  final Map<String, dynamic> funcionario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloMovimentacoesFuncionario',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.cyan,
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
                tag: 'listTileMovimentacoesFuncionario$i',
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
                    leading: movimentacoes[i]['idFuncionarioSolicitador'] ==
                            funcionario['idFuncionario']
                        ? Icon(
                            Icons.description_outlined,
                            color: Colors.green.withValues(alpha: 0.5),
                          )
                        : Icon(
                            Icons.vpn_key_outlined,
                            color: Colors.yellow.withValues(alpha: 0.5),
                          ),
                    title: Text(
                      movimentacoes[i]['descricaoProduto'],
                    ),
                    subtitle: Text(
                      '${movimentacoes[i]['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yyyy, HH:mm').format(
                        DateTime.parse(movimentacoes[i]['dataHora']),
                      )}',
                    ),
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
