import 'package:flutter/material.dart';
import 'package:front_mercado/pages/estoques/estoques_detalhes_page.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_detalhes_page.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacao_estoque_detalhes_card_page.dart';
import 'package:front_mercado/pages/produtos/produtos_detalhes_page.dart';
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MovimentacaoEstoqueDetalhesCardPage(
                                movimentacao: movimentacao),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloMovimentacaoEstoqueCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.inventory_2,
                              color: Colors.cyan,
                            ),
                            title: Text('Movimentação'),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'listTileMovimentacaoEstoqueCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.cyan.withValues(alpha: 0.5),
                            ),
                            title: Text(
                                movimentacao['descricaoMovimentacaoEstoque']),
                            subtitle: Text(dataFormatada),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: GestureDetector(
                  onTap: () {
                    final produto = {
                      'idProduto': movimentacao['idProduto'],
                      'codBarras': movimentacao['codBarrasProduto'],
                      'descricao': movimentacao['descricaoProduto']
                    };

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProdutosDetalhesPage(produto: produto),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloProdutosDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.shopping_bag,
                              color: Colors.green,
                            ),
                            title: Text('Produto'),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'listTileProdutosDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.green.withValues(alpha: 0.5),
                            ),
                            title: Text(movimentacao['descricaoProduto']),
                            subtitle: Text(movimentacao['codBarrasProduto']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: GestureDetector(
                  onTap: () {
                    final estoque = {
                      'idEstoque': movimentacao['idEstoque'],
                      'idTipoEstoque': movimentacao['idTipoEstoque'],
                      'descricaoEstoque': movimentacao['descricaoEstoque'],
                      'descricaoTipoEstoque':
                          movimentacao['descricaoTipoEstoque'],
                    };

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EstoqueDetalhesPage(estoque: estoque),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloEstoqueDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.warehouse,
                              color: Colors.yellow,
                            ),
                            title: Text('Estoque'),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'listTileEstoqueDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.warehouse_outlined,
                              color: Colors.yellow.withValues(alpha: 0.5),
                            ),
                            title: Text(movimentacao['descricaoEstoque']),
                            subtitle:
                                Text(movimentacao['descricaoTipoEstoque']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: GestureDetector(
                  onTap: () {
                    final funcionario = {
                      'idFuncionario': movimentacao['idFuncionarioSolicitador'],
                      'nome': movimentacao['nomeFuncionarioSolicitador'],
                      'setor': movimentacao['setorFuncionarioSolicitador'],
                      'email': movimentacao['emailFuncionarioSolicitador']
                    };

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            FuncionariosDetalhesPage(funcionario: funcionario),
                      ),
                    );
                  },
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
                child: GestureDetector(
                  onTap: () {
                    final funcionario = {
                      'idFuncionario': movimentacao['idFuncionarioSolicitador'],
                      'nome': movimentacao['nomeFuncionarioSolicitador'],
                      'setor': movimentacao['setorFuncionarioSolicitador'],
                      'email': movimentacao['emailFuncionarioSolicitador']
                    };

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            FuncionariosDetalhesPage(funcionario: funcionario),
                      ),
                    );
                  },
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
