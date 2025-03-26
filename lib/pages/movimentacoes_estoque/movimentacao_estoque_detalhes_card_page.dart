import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovimentacaoEstoqueDetalhesCardPage extends StatelessWidget {
  const MovimentacaoEstoqueDetalhesCardPage({
    super.key,
    required this.movimentacao,
  });

  final Map<String, dynamic> movimentacao;

  @override
  Widget build(BuildContext context) {
    final data = DateTime.parse(movimentacao['dataHora']);
    final dataFormatada = DateFormat('dd/MM/yyyy, HH:mm').format(data);

    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloMovimentacaoEstoqueCard',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.inventory_2,
                color: Colors.cyan,
              ),
              title: Text(
                'Movimentação',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: Hero(
        tag: 'listTileMovimentacaoEstoqueCard',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              Icons.inventory_2_outlined,
              color: Colors.cyan.withAlpha(128),
            ),
            title: Text(movimentacao['descricaoMovimentacaoEstoque']),
            subtitle: Text(dataFormatada),
          ),
        ),
      ),
    );
  }
}
