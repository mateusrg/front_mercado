import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DialogPesquisaTipoMovimentacaoEstoque extends StatefulWidget {
  const DialogPesquisaTipoMovimentacaoEstoque({super.key});

  @override
  State<DialogPesquisaTipoMovimentacaoEstoque> createState() =>
      _DialogPesquisaTipoMovimentacaoEstoqueState();
}

class _DialogPesquisaTipoMovimentacaoEstoqueState
    extends State<DialogPesquisaTipoMovimentacaoEstoque> {
  final TextEditingController _pesquisaController = TextEditingController();
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _resultados = [];
  bool _carregando = false;

  Future<void> _pesquisarTiposMovimentacaoEstoque(String texto) async {
    setState(() => _carregando = true);
    try {
      final response = await http.post(
        Uri.http(apiUrl, 'TiposMovimentacaoEstoque/descricao'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': texto}),
      );

      if (response.statusCode == 200) {
        setState(() => _resultados =
            List<Map<String, dynamic>>.from(json.decode(response.body)));
      } else {
        _mostrarErro('Erro na pesquisa: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Erro de conexão');
    } finally {
      setState(() => _carregando = false);
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
    super.initState();
    _pesquisarTiposMovimentacaoEstoque('');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pesquisar Tipo de Movimentação de Estoque'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pesquisaController,
            decoration: InputDecoration(
              labelText: 'Descrição',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _pesquisarTiposMovimentacaoEstoque(
                    _pesquisaController.text),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _carregando
              ? const CircularProgressIndicator()
              : _resultados.isEmpty
                  ? const Center(
                      child: ListTile(
                        title: Center(
                          child: Text(
                            'Nenhum tipo de movimentação de estoque encontrado.',
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _resultados.length,
                        itemBuilder: (context, index) {
                          final tipoMovimentacaoEstoque = _resultados[index];
                          return ListTile(
                            title: Text(tipoMovimentacaoEstoque['descricao']),
                            onTap: () =>
                                Navigator.pop(context, tipoMovimentacaoEstoque),
                          );
                        },
                      ),
                    ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }
}
