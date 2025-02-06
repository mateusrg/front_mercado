import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class FornecedoresPage extends StatefulWidget {
  const FornecedoresPage({super.key});

  @override
  State<FornecedoresPage> createState() => _FornecedoresPageState();
}

class _FornecedoresPageState extends State<FornecedoresPage> {
  final String apiUrl = '10.0.2.2:5277';
  List<Map<String, dynamic>> _fornecedores = [];

  @override
  void initState() {
    _listarFornecedores();
    super.initState();
  }

  Future<void> _listarFornecedores() async {
    final response = await http.get(Uri.http(apiUrl, '/Fornecedores'));

    if (response.statusCode == 200) {
      setState(() {
        _fornecedores =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Erro ao listar fornecedores: ${response.statusCode}');
    }
  }

  Future<void> _adicionarFornecedor(Map<String, dynamic> fornecedor) async {
    final response = await http.post(
      Uri.http(apiUrl, '/Fornecedores'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(fornecedor),
    );

    if (response.statusCode < 400) {
      _listarFornecedores();
    } else {
      print('Erro ao adicionar fornecedor: ${response.statusCode}');
    }
  }

  Future<void> _editarFornecedor(Map<String, dynamic> fornecedor) async {
    final response = await http.put(
      Uri.http(apiUrl, '/Fornecedores'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(fornecedor),
    );

    if (response.statusCode < 400) {
      _listarFornecedores();
    } else {
      print('Erro ao editar fornecedor: ${response.statusCode}');
    }
  }

  void _abrirFormularioFornecedor({Map<String, dynamic>? fornecedor}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FornecedorFormPage(
          fornecedor: fornecedor,
          onSave: (fornecedor) {
            if (fornecedor.containsKey('idFornecedor')) {
              _editarFornecedor(fornecedor);
            } else {
              _adicionarFornecedor(fornecedor);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
      ),
      body: ListView.builder(
        itemCount: _fornecedores.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_fornecedores[index]['nome']),
            subtitle: Text('${_fornecedores[index]['cnpj']}'),
            onTap: () =>
                _abrirFormularioFornecedor(fornecedor: _fornecedores[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioFornecedor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FornecedorFormPage extends StatefulWidget {
  final Map<String, dynamic>? fornecedor;
  final Function(Map<String, dynamic>) onSave;

  const FornecedorFormPage({super.key, this.fornecedor, required this.onSave});

  @override
  State<FornecedorFormPage> createState() => _FornecedorFormPageState();
}

class _FornecedorFormPageState extends State<FornecedorFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late MaskedTextController _cnpjController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.fornecedor != null ? widget.fornecedor!['nome'] : '',
    );
    _cnpjController = MaskedTextController(
      mask: '00.000.000/0000-00',
      text: widget.fornecedor != null ? widget.fornecedor!['cnpj'] : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final fornecedor = {
        'nome': _nomeController.text,
        'cnpj': _cnpjController.text,
      };

      if (widget.fornecedor != null) {
        fornecedor['idFornecedor'] = widget.fornecedor!['idFornecedor'].toString();
      }

      widget.onSave(fornecedor);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(labelText: 'CNPJ'),
                maxLength: 18,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CNPJ';
                  }
                  if (value.length != 18) {
                    return 'O CNPJ deve ter 18 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
