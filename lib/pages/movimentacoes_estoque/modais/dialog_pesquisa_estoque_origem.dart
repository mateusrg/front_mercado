import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DialogPesquisaEstoqueOrigem extends StatefulWidget {
  const DialogPesquisaEstoqueOrigem({super.key});

  @override
  State<DialogPesquisaEstoqueOrigem> createState() =>
      _DialogPesquisaEstoqueOrigemState();
}

class _DialogPesquisaEstoqueOrigemState
    extends State<DialogPesquisaEstoqueOrigem> {
  final TextEditingController _pesquisaController = TextEditingController();
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _resultadosPesquisa = [];
  bool _carregando = false;

  Future<void> _pesquisarEstoques(String texto) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http.post(
        Uri.http(apiUrl, 'Estoques/tipo-estoque'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'descricaoEstoque': texto}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _resultadosPesquisa =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _mostrarErro('Erro ao pesquisar estoques: ${response.statusCode}');
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
    _pesquisarEstoques('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pesquisar Estoque de Origem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pesquisaController,
            decoration: InputDecoration(
              labelText: 'Pesquisar',
              suffixIcon: IconButton(
                  onPressed: () {
                    _pesquisarEstoques(_pesquisaController.text);
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
                            'Nenhum estoque encontrado.',
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _resultadosPesquisa.length,
                        itemBuilder: (context, index) {
                          final estoque = _resultadosPesquisa[index];
                          return ListTile(
                            title: Text(estoque['descricaoEstoque']),
                            subtitle: Text(estoque['descricaoTipoEstoque']),
                            onTap: () {
                              Navigator.pop(context, estoque);
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
