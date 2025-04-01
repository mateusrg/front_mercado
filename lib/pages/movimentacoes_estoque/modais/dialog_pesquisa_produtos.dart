import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DialogPesquisaProduto extends StatefulWidget {
  const DialogPesquisaProduto({super.key});

  @override
  State<DialogPesquisaProduto> createState() => _DialogPesquisaProdutoState();
}

class _DialogPesquisaProdutoState extends State<DialogPesquisaProduto> {
  final TextEditingController _pesquisaController = TextEditingController();
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _resultadosPesquisa = [];
  bool _carregando = false;

  Future<void> _pesquisarProdutos(String texto) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http.post(
        Uri.http(apiUrl, 'Produtos/tudo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': texto}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _resultadosPesquisa =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _mostrarErro('Erro ao pesquisar produtos: ${response.statusCode}');
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
    _pesquisarProdutos('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pesquisar Produto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pesquisaController,
            decoration: InputDecoration(
              labelText: 'Pesquisar',
              suffixIcon: IconButton(
                  onPressed: () {
                    _pesquisarProdutos(_pesquisaController.text);
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
                            'Nenhum produto encontrado.',
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _resultadosPesquisa.length,
                        itemBuilder: (context, index) {
                          final produto = _resultadosPesquisa[index];
                          return ListTile(
                            title: Text(produto['descricao']),
                            subtitle: Text(produto['codBarras']),
                            onTap: () {
                              Navigator.pop(context, produto);
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
