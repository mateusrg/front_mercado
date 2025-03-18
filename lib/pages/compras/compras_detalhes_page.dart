import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompraDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> compra;

  const CompraDetalhesPage({super.key, required this.compra});

  @override
  Widget build(BuildContext context) {
    final data = DateTime.parse(compra['data']);
    final dataFormatada = DateFormat('dd/MM/yyyy, HH:mm').format(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Compra'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantidade: ${compra['quantidade']} unidades'),
                    Text('Data: $dataFormatada'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.production_quantity_limits),
                title: const Text('Produto'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descrição: ${compra['descricaoProduto']}'),
                    Text('Código de Barras: ${compra['codBarrasProduto']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Fornecedor'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nome: ${compra['nomeFornecedor']}'),
                    Text('CNPJ: ${compra['cnpjFornecedor']}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
