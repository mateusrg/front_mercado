import 'package:flutter/material.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_detalhes_card_page.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_form_page.dart';
import 'package:front_mercado/pages/funcionarios/movimentacoes_de_estoque_funcionario_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:front_mercado/params.dart';

class FuncionariosDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> funcionario;

  const FuncionariosDetalhesPage({super.key, required this.funcionario});

  @override
  State<FuncionariosDetalhesPage> createState() =>
      _FuncionariosDetalhesPageState();
}

class _FuncionariosDetalhesPageState extends State<FuncionariosDetalhesPage> {
  static const String apiUrl = Params.apiUrl;
  List<dynamic> movimentacoes = [];
  bool carregandoMovimentacoes = true;

  @override
  void initState() {
    super.initState();
    carregarMovimentacoes();
  }

  Future<void> carregarMovimentacoes() async {
    final response = await http.get(Uri.http(apiUrl,
        'Funcionarios/movimentacoesFuncionario/${widget.funcionario['idFuncionario']}'));
    if (response.statusCode == 200) {
      setState(() {
        movimentacoes = json.decode(response.body);
        carregandoMovimentacoes = false;
      });
    } else {
      setState(() {
        carregandoMovimentacoes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Funcionário'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final funcionarioRecebido = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  FuncionariosFormPage(funcionario: widget.funcionario),
            ),
          );

          if (funcionarioRecebido != null) {
            setState(() {
              widget.funcionario['nome'] = funcionarioRecebido['nome'];
              widget.funcionario['email'] = funcionarioRecebido['email'];
              widget.funcionario['setor'] = funcionarioRecebido['setor'];
            });
          }
        },
        child: const Icon(Icons.edit),
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
                        builder: (context) => FuncionariosDetalhesCardPage(
                            funcionario: widget.funcionario),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloFuncionariosDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.person,
                              color: Colors.cyan,
                            ),
                            title: Text('Funcionário'),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'listTileFuncionariosDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.person_outline,
                              color: Colors.cyan.withAlpha(128),
                            ),
                            title: Text(widget.funcionario['nome']),
                            subtitle: Text(widget.funcionario['email']),
                            trailing: Text(widget.funcionario['setor']),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovimentacoesFuncionarioPage(
                          movimentacoes: movimentacoes,
                          funcionario: widget.funcionario,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloMovimentacoesFuncionario',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.history,
                              color: Colors.cyan,
                            ),
                            title: Text('Movimentações'),
                          ),
                        ),
                      ),
                      carregandoMovimentacoes
                          ? const Center(child: CircularProgressIndicator())
                          : movimentacoes.isEmpty
                              ? Center(
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
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0;
                                        i <
                                            (movimentacoes.length > 3
                                                ? 3
                                                : movimentacoes.length);
                                        i++)
                                      Hero(
                                        tag:
                                            'listTileMovimentacoesFuncionario$i',
                                        child: Material(
                                          color: Colors.transparent,
                                          child: ListTile(
                                            leading: movimentacoes[i][
                                                        'idFuncionarioSolicitador'] ==
                                                    widget.funcionario[
                                                        'idFuncionario']
                                                ? Icon(
                                                    Icons.description_outlined,
                                                    color: Colors.green
                                                        .withValues(alpha: 0.5),
                                                  )
                                                : Icon(
                                                    Icons.vpn_key_outlined,
                                                    color: Colors.yellow
                                                        .withValues(alpha: 0.5),
                                                  ),
                                            title: Text(
                                              movimentacoes[i]
                                                  ['descricaoProduto'],
                                            ),
                                            subtitle: Text(
                                              '${movimentacoes[i]['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yyyy, HH:mm').format(
                                                DateTime.parse(movimentacoes[i]
                                                    ['dataHora']),
                                              )}',
                                            ),
                                            trailing: Text(
                                                '${movimentacoes[i]['quantidade'].abs()} un.'),
                                          ),
                                        ),
                                      ),
                                    if (movimentacoes.length > 3)
                                      ListTile(
                                          leading: Icon(
                                            Icons.add,
                                            color: Colors.grey
                                                .withValues(alpha: 0.5),
                                          ),
                                          title: const Text('E mais...')),
                                  ],
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
