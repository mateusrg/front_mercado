import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;

class ProdutosFormPage extends StatefulWidget {
  final Map<String, dynamic>? produto;

  const ProdutosFormPage({super.key, this.produto});

  @override
  State<ProdutosFormPage> createState() => _ProdutosFormPageState();
}

class _ProdutosFormPageState extends State<ProdutosFormPage> {
  final String apiUrl = '${Params.ipApi}:5277';
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late MaskedTextController _codbarrasController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(
      text: widget.produto != null ? widget.produto!['descricao'] : '',
    );
    _codbarrasController = MaskedTextController(
      mask: '0000000000000',
      text: widget.produto != null ? widget.produto!['codBarras'] : '',
    );
  }

  Future<void> _editarProduto(Map<String, dynamic> produto) async {
    try {
      final response = await http
          .put(
            Uri.http(apiUrl, '/Produtos'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(produto),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro('Erro ao editar produto: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _adicionarProduto(Map<String, dynamic> produto) async {
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Produtos'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(produto),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro('Erro ao adicionar produto: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _codbarrasController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _salvando = true;
      });

      var produto = {
        'descricao': _descricaoController.text,
        'codBarras': _codbarrasController.text,
      };

      if (widget.produto != null) {
        produto['idProduto'] = widget.produto!['idProduto'].toString();
      }

      try {
        if (produto.containsKey('idProduto')) {
          await _editarProduto(produto);
        } else {
          await _adicionarProduto(produto);
        }
        Navigator.of(context).pop(produto);
      } catch (e) {
        _mostrarErro('Não foi possível se conectar com a API.');
      } finally {
        setState(() {
          _salvando = false;
        });
      }
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
  Widget build(BuildContext content) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _salvar(),
              ),
              TextFormField(
                controller: _codbarrasController,
                decoration:
                    const InputDecoration(labelText: 'Código de Barras'),
                maxLength: 13,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o Código de Barras';
                  }
                  if (value.length != 13) {
                    return 'O Código de barras deve ter 13 caracteres';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _salvar(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text(widget.produto == null ? 'Cadastrar' : 'Alterar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
