import 'package:flutter/material.dart';

class EstoqueDetalhesCardPage extends StatefulWidget {
  const EstoqueDetalhesCardPage({
    super.key,
    required this.estoque,
  });

  final Map<String, dynamic> estoque;

  @override
  State<EstoqueDetalhesCardPage> createState() =>
      _EstoqueDetalhesCardPageState();
}

class _EstoqueDetalhesCardPageState extends State<EstoqueDetalhesCardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloEstoqueDetalhesCard',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.warehouse,
                color: Colors.cyan,
              ),
              title: Text(
                'Estoque',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: Hero(
        tag: 'listTileEstoqueDetalhesCard',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              Icons.warehouse_outlined,
              color: Colors.cyan.withAlpha(128),
            ),
            title: Text(widget.estoque['descricaoEstoque']),
            subtitle: Text(widget.estoque['descricaoTipoEstoque'] ?? 'N/A'),
          ),
        ),
      ),
    );
  }
}
