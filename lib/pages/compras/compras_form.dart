import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CompraFormPage extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onSave;

  const CompraFormPage({super.key, required this.onSave});

  @override
  State<CompraFormPage> createState() => _CompraFormPageState();
}

const String apiUrl = '${Params.ipApi}:5277';

class _CompraFormPageState extends State<CompraFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantidadeController;
  bool _salvando = false;
  bool _carregando = true;
  DateTime? _dataSelecionada;
  List<Map<String, dynamic>> _fornecedores = [];
  List<Map<String, dynamic>> _produtos = [];
  Map<String, dynamic>? _fornecedorSelecionado;
  Map<String, dynamic>? _produtoSelecionado;

  @override
  void initState() {
    super.initState();
    _quantidadeController = TextEditingController();
    _carregarFornecedoresEProdutos();
  }

  Future<void> _carregarFornecedoresEProdutos() async {
    await _carregarFornecedores();
    await _carregarProdutos();
    setState(() {
      _carregando = false;
    });
  }

  Future<void> _carregarFornecedores() async {
    final response = await http.get(Uri.http(apiUrl, '/Fornecedores'));
    if (response.statusCode == 200) {
      setState(() {
        _fornecedores =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      _mostrarErro('Erro ao carregar fornecedores: ${response.statusCode}');
    }
  }

  Future<void> _carregarProdutos() async {
    final response = await http.get(Uri.http(apiUrl, '/Produtos'));
    if (response.statusCode == 200) {
      setState(() {
        _produtos = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      _mostrarErro('Erro ao carregar produtos: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? selecionado = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(1),
      lastDate: DateTime(9999),
      locale: const Locale('pt', 'BR'),
    );
    if (selecionado != null && selecionado != _dataSelecionada) {
      setState(() {
        _dataSelecionada = selecionado;
      });
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate() && _dataSelecionada != null) {
      setState(() {
        _salvando = true;
      });

      final compra = {
        'idFornecedor': _fornecedorSelecionado!['idFornecedor'],
        'idProduto': _produtoSelecionado!['idProduto'],
        'data': _dataSelecionada!.toIso8601String(),
        'quantidade': _quantidadeController.text,
      };

      try {
        await widget.onSave(compra);
        Navigator.of(context).pop();
      } catch (e) {
        _mostrarErro('Não foi possível se conectar com a API.');
      } finally {
        setState(() {
          _salvando = false;
        });
      }
    } else if (_dataSelecionada == null) {
      _mostrarErro('Por favor, selecione uma data.');
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
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Compra'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _fornecedorSelecionado,
                decoration: const InputDecoration(labelText: 'Fornecedor'),
                items: _fornecedores.map((fornecedor) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: fornecedor,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      child: Text(
                        '${fornecedor['nome']} - ${fornecedor['cnpj']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _fornecedorSelecionado = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um fornecedor';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _produtoSelecionado,
                decoration: const InputDecoration(labelText: 'Produto'),
                items: _produtos.map((produto) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: produto,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      child: Text(
                        '${produto['descricao']} - ${produto['codBarras']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _produtoSelecionado = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um produto';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantidadeController,
                      decoration:
                          const InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a quantidade';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selecionarData(context),
                  ),
                  Text(
                    _dataSelecionada != null
                        ? DateFormat('dd/MM/yyyy').format(_dataSelecionada!)
                        : 'Informe a data',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
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
                    : const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
