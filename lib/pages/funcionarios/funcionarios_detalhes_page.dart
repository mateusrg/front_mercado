import 'package:flutter/material.dart';
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
  final String apiUrl = '${Params.ipApi}:5277';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Funcionário'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nome: ${widget.funcionario['nome']}'),
                      Text('Setor: ${widget.funcionario['setor']}'),
                      Text('Email: ${widget.funcionario['email']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Movimentações de Estoque'),
                    ),
                    carregandoMovimentacoes
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0;
                                  i <
                                      (movimentacoes.length > 3
                                          ? 3
                                          : movimentacoes.length);
                                  i++)
                                ListTile(
                                  leading: movimentacoes[i]
                                              ['idFuncionarioSolicitador'] ==
                                          widget.funcionario['idFuncionario']
                                      ? const Icon(
                                          Icons.vpn_key_outlined,
                                          color: Colors.yellow,
                                        )
                                      : const Icon(
                                          Icons.description_outlined,
                                          color: Colors.green,
                                        ),
                                  title: Text(
                                    movimentacoes[i]['descricaoProduto'],
                                  ),
                                  subtitle: Text(
                                    '${movimentacoes[i]['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yyyy, HH:mm').format(
                                      DateTime.parse(
                                          movimentacoes[i]['dataHora']),
                                    )}',
                                  ),
                                  trailing: Text(
                                      '${movimentacoes[i]['quantidade'].abs()} un.'),
                                ),
                              if (movimentacoes.length > 3)
                                const ListTile(title: Text('E mais...')),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
