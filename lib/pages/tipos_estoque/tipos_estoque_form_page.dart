import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;

class TipoEstoqueFormPage extends StatefulWidget {
  final Map<String, dynamic>? tipoEstoque;

  const TipoEstoqueFormPage({super.key, this.tipoEstoque});

  @override
  State<TipoEstoqueFormPage> createState() => _TipoEstoqueFormPageState();
}

class _TipoEstoqueFormPageState extends State<TipoEstoqueFormPage> {
  static const String apiUrl = Params.apiUrl;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(
      text: widget.tipoEstoque != null ? widget.tipoEstoque!['descricao'] : '',
    );
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _adicionarTipoEstoque(Map<String, dynamic> tipoEstoque) async {
    tipoEstoque['idTipoEstoque'] = 0;
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/TiposEstoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(tipoEstoque),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro(
            'Erro ao adicionar tipo de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _editarTipoEstoque(Map<String, dynamic> tipoEstoque) async {
    try {
      final response = await http
          .put(
            Uri.http(apiUrl, '/TiposEstoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(tipoEstoque),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro('Erro ao editar tipo de estoque: ${response.statusCode}');
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

      final tipoEstoque = {
        'idTipoEstoque': widget.tipoEstoque?['idTipoEstoque'],
        'descricao': _descricaoController.text,
      };

      if (tipoEstoque['idTipoEstoque'] != null) {
        await _editarTipoEstoque(tipoEstoque);
      } else {
        await _adicionarTipoEstoque(tipoEstoque);
      }

      setState(() {
        _salvando = false;
      });

      Navigator.of(context).pop(tipoEstoque);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo Estoque'),
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
                      child: Text(
                        widget.tipoEstoque == null ? 'Cadastrar' : 'Alterar',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
