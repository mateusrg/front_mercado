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
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.inventory, color: Colors.cyan),
                        title: Text('Movimentação'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.inventory,
                          color: Colors.cyan.withValues(alpha: 0.5),
                        ),
                        title:
                            Text(movimentacao['descricaoMovimentacaoEstoque']),
                        subtitle: Text(dataFormatada),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.shopping_bag, color: Colors.green),
                        title: Text('Produto'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.green.withValues(alpha: 0.5),
                        ),
                        title: Text(movimentacao['descricaoProduto']),
                        subtitle: Text(movimentacao['codBarrasProduto']),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.warehouse, color: Colors.yellow),
                        title: Text('Estoque'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.warehouse_outlined,
                          color: Colors.yellow.withValues(alpha: 0.5),
                        ),
                        title: Text(movimentacao['descricaoEstoque']),
                        subtitle: Text(movimentacao['descricaoTipoEstoque']),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.person, color: Colors.blue),
                        title: Text('Funcionário Solicitador'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: Colors.blue.withValues(alpha: 0.5),
                        ),
                        title: Text(movimentacao['nomeFuncionarioSolicitador']),
                        subtitle:
                            Text(movimentacao['emailFuncionarioSolicitador']),
                        trailing:
                            Text(movimentacao['setorFuncionarioSolicitador']),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(
                          Icons.person_search,
                          color: Colors.indigoAccent,
                        ),
                        title: Text('Funcionário Autenticador'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.person_search_outlined,
                          color: Colors.indigoAccent.withValues(alpha: 0.5),
                        ),
                        title:
                            Text(movimentacao['nomeFuncionarioAutenticador']),
                        subtitle:
                            Text(movimentacao['emailFuncionarioAutenticador']),
                        trailing:
                            Text(movimentacao['setorFuncionarioAutenticador']),
                      ),
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
