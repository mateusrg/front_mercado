import 'package:flutter/material.dart';

class FornecedoresDetalhesCardPage extends StatelessWidget {
  const FornecedoresDetalhesCardPage({
    super.key,
    required this.fornecedor,
  });

  final Map<String, dynamic> fornecedor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloFornecedoresDetalhesCard',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.business,
                color: Colors.cyan,
              ),
              title: Text(
                'Fornecedor',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: Hero(
        tag: 'listTileFornecedoresDetalhesCard',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              Icons.business_outlined,
              color: Colors.cyan.withAlpha(128),
            ),
            title: Text(fornecedor['nome']),
            subtitle: Text(fornecedor['cnpj']),
          ),
        ),
      ),
    );
  }
}
