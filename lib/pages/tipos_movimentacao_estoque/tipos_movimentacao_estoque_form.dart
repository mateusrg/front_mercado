import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;

class TipoMovimentacaoEstoqueFormPage extends StatefulWidget {
  final Map<String, dynamic>? tipoMovimentacaoEstoque;

  const TipoMovimentacaoEstoqueFormPage(
      {super.key, required this.tipoMovimentacaoEstoque});

  @override
  State<TipoMovimentacaoEstoqueFormPage> createState() =>
      _TipoMovimentacaoEstoqueFormPageState();
}

class _TipoMovimentacaoEstoqueFormPageState
    extends State<TipoMovimentacaoEstoqueFormPage> {
  static const String apiUrl = Params.apiUrl;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(
      text: widget.tipoMovimentacaoEstoque != null
          ? widget.tipoMovimentacaoEstoque!['descricao']
          : '',
    );
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
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

  Future<void> _adicionarTipoMovimentacaoEstoque(
      Map<String, dynamic> tipoMovimentacaoEstoque) async {
    try {
      tipoMovimentacaoEstoque['idTipoMovimentacaoEstoque'] = 0;
      final response = await http
          .post(
            Uri.http(apiUrl, '/TiposMovimentacaoEstoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(tipoMovimentacaoEstoque),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro(
            'Erro ao adicionar tipo de movimentação de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _editarTipoMovimentacaoEstoque(
      Map<String, dynamic> tipoMovimentacaoEstoque) async {
    try {
      final response = await http
          .put(
            Uri.http(apiUrl, '/TiposMovimentacaoEstoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(tipoMovimentacaoEstoque),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro(
            'Erro ao editar tipo de movimentação de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _salvando = true;
      });

      final m = {
        'idTipoMovimentacaoEstoque':
            widget.tipoMovimentacaoEstoque?['idTipoMovimentacaoEstoque'],
        'descricao': _descricaoController.text,
      };

      if (widget.tipoMovimentacaoEstoque?['idTipoMovimentacaoEstoque'] !=
          null) {
        await _editarTipoMovimentacaoEstoque(m);
      } else {
        await _adicionarTipoMovimentacaoEstoque(m);
      }

      setState(() {
        _salvando = false;
      });

      if (mounted) Navigator.of(context).pop(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de Movimentação de Estoque'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _salvar(),
              ),
              const SizedBox(height: 20.0),
              _salvando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(widget.tipoMovimentacaoEstoque == null
                          ? 'Cadastrar'
                          : 'Alterar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
