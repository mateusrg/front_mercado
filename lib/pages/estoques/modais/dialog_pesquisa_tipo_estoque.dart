import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DialogPesquisaTipoEstoque extends StatefulWidget {
  const DialogPesquisaTipoEstoque({super.key});

  @override
  State<DialogPesquisaTipoEstoque> createState() =>
      _DialogPesquisaTipoEstoqueState();
}

class _DialogPesquisaTipoEstoqueState extends State<DialogPesquisaTipoEstoque> {
  final TextEditingController _pesquisaController = TextEditingController();
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _resultados = [];
  bool _carregando = false;

  Future<void> _pesquisarTiposEstoque(String texto) async {
    setState(() => _carregando = true);
    try {
      final response = await http.post(
        Uri.http(apiUrl, 'TiposEstoque/descricao'),
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem), backgroundColor: Colors.red));
  }

  @override
  void initState() {
    super.initState();
    _pesquisarTiposEstoque('');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pesquisar Tipo de Estoque'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pesquisaController,
            decoration: InputDecoration(
              labelText: 'Pesquisar',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () =>
                    _pesquisarTiposEstoque(_pesquisaController.text),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _carregando
              ? const CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _resultados.length,
                    itemBuilder: (context, index) {
                      final tipoEstoque = _resultados[index];
                      return ListTile(
                        title: Text(tipoEstoque['descricao']),
                        onTap: () => Navigator.pop(context, tipoEstoque),
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
