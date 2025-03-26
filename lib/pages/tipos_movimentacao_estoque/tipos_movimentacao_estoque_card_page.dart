import 'package:flutter/material.dart';

class TiposMovimentacaoEstoqueCardPage extends StatelessWidget {
  const TiposMovimentacaoEstoqueCardPage({
    super.key,
    required this.tipoMovimentacaoEstoque,
  });

  final Map<String, dynamic> tipoMovimentacaoEstoque;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloTiposMovimentacaoEstoqueCard',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.move_down_rounded,
                color: Colors.cyan,
              ),
              title: Text(
                'Tipo',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: Hero(
        tag: 'listTileTiposMovimentacaoEstoqueCard',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              Icons.move_down_outlined,
              color: Colors.cyan.withAlpha(128),
            ),
            title: Text(tipoMovimentacaoEstoque['descricao']),
          ),
        ),
      ),
    );
  }
}
