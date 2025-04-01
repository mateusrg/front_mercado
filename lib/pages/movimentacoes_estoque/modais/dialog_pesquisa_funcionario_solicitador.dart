import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DialogPesquisaFuncionarioSolicitador extends StatefulWidget {
  const DialogPesquisaFuncionarioSolicitador({super.key});

  @override
  State<DialogPesquisaFuncionarioSolicitador> createState() =>
      _DialogPesquisaFuncionarioSolicitadorState();
}

class _DialogPesquisaFuncionarioSolicitadorState
    extends State<DialogPesquisaFuncionarioSolicitador> {
  final TextEditingController _pesquisaController = TextEditingController();
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _resultadosPesquisa = [];
  bool _carregando = false;

  Future<void> _pesquisarFuncionarios(String texto) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http.post(
        Uri.http(apiUrl, 'Funcionarios/IdNomeSetorEmail'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': texto}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _resultadosPesquisa =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _mostrarErro('Erro ao pesquisar funcionários: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _mostrarErro(String mensagem) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {}
  }

  @override
  void initState() {
    _pesquisarFuncionarios('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pesquisar Funcionário Solicitador'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pesquisaController,
            decoration: InputDecoration(
              labelText: 'Pesquisar',
              suffixIcon: IconButton(
                  onPressed: () {
                    _pesquisarFuncionarios(_pesquisaController.text);
                  },
                  icon: const Icon(Icons.search)),
            ),
          ),
          const SizedBox(height: 16.0),
          _carregando
              ? const CircularProgressIndicator()
              : _resultadosPesquisa.isEmpty
                  ? const Center(
                      child: ListTile(
                        title: Center(
                          child: Text(
                            'Nenhum funcionário encontrado.',
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _resultadosPesquisa.length,
                        itemBuilder: (context, index) {
                          final funcionario = _resultadosPesquisa[index];
                          return ListTile(
                            title: Text(funcionario['nome']),
                            subtitle: Text(funcionario['email']),
                            trailing: Text(funcionario['setor']),
                            onTap: () {
                              Navigator.pop(context, funcionario);
                            },
                          );
                        },
                      ),
                    ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
