import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovimentacaoDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> movimentacao;

  const MovimentacaoDetalhesPage({super.key, required this.movimentacao});

  @override
  Widget build(BuildContext context) {
    final data = DateTime.parse(movimentacao['dataHora']);
    final dataFormatada = DateFormat('dd/MM/yyyy, HH:mm').format(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Movimentação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('Movimentação'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Tipo: ${movimentacao['descricaoMovimentacaoEstoque']}'),
                      Text('Quantidade: ${movimentacao['quantidade'].abs()}'),
                      Text('Data: $dataFormatada'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('Produto'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descrição: ${movimentacao['descricaoProduto']}'),
                      Text(
                          'Código de Barras: ${movimentacao['codBarrasProduto']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.warehouse),
                  title: const Text('Estoque'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descrição: ${movimentacao['descricaoEstoque']}'),
                      Text('Tipo: ${movimentacao['descricaoTipoEstoque']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Funcionário Solicitador'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Nome: ${movimentacao['nomeFuncionarioSolicitador']}'),
                      Text(
                          'Setor: ${movimentacao['setorFuncionarioSolicitador']}'),
                      Text(
                          'Email: ${movimentacao['emailFuncionarioSolicitador']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Funcionário Autenticador'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Nome: ${movimentacao['nomeFuncionarioAutenticador']}'),
                      Text(
                          'Setor: ${movimentacao['setorFuncionarioAutenticador']}'),
                      Text(
                          'Email: ${movimentacao['emailFuncionarioAutenticador']}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
