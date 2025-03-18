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
  final urlApi = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _resultadosPesquisa = [];
  bool _carregando = false;

  Future<void> _pesquisarProdutos(String texto) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http.get(Uri.http(urlApi, 'Produtos/tudo/$texto'));
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
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
