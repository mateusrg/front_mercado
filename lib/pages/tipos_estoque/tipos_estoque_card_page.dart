import 'package:flutter/material.dart';

class TiposEstoqueCardPage extends StatelessWidget {
  const TiposEstoqueCardPage({
    super.key,
    required this.tipoEstoque,
  });

  final Map<String, dynamic> tipoEstoque;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloTiposEstoqueCard',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.inventory_rounded,
                color: Colors.cyan,
              ),
              title: Text(
                'Tipo de Estoque',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: Hero(
        tag: 'listTileTiposEstoqueCard',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              Icons.inventory_outlined,
              color: Colors.cyan.withAlpha(128),
            ),
            title: Text(tipoEstoque['descricao']),
          ),
        ),
      ),
    );
  }
}
