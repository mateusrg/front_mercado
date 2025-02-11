import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/widgets/drawer.dart';
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
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarFornecedores();
    super.initState();
  }

  Future<void> _listarFornecedores([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .get(Uri.http(
              apiUrl,
              query != null && query != ''
                  ? '/Fornecedores/nomeECnpj/$query'
                  : '/Fornecedores'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _fornecedores =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar fornecedores: ${response.statusCode}');
        setState(() {
          _carregando = false;
        });
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _adicionarFornecedor(Map<String, dynamic> fornecedor) async {
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Fornecedores'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(fornecedor),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarFornecedores();
      } else {
        _mostrarErro('Erro ao adicionar fornecedor: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _editarFornecedor(Map<String, dynamic> fornecedor) async {
    try {
      final response = await http
          .put(
            Uri.http(apiUrl, '/Fornecedores'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(fornecedor),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarFornecedores();
      } else {
        _mostrarErro('Erro ao editar fornecedor: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioFornecedor({Map<String, dynamic>? fornecedor}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FornecedorFormPage(
          fornecedor: fornecedor,
          onSave: (fornecedor) async {
            if (fornecedor.containsKey('idFornecedor')) {
              await _editarFornecedor(fornecedor);
            } else {
              await _adicionarFornecedor(fornecedor);
            }
          },
        ),
      ),
    );
  }

  void _pesquisarFornecedores() {
    _listarFornecedores(_pesquisaController.text);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
      ),
      drawer: const DrawerFenomenos(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesquisaController,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _pesquisarFornecedores,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _fornecedores.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_fornecedores[index]['nome']),
                        subtitle: Text(_fornecedores[index]['cnpj']),
                        onTap: () => _abrirFormularioFornecedor(
                            fornecedor: _fornecedores[index]),
                      );
                    },
                  ),
          ),
        ],
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
  final Future<void> Function(Map<String, dynamic>) onSave;

  const FornecedorFormPage({super.key, this.fornecedor, required this.onSave});

  @override
  State<FornecedorFormPage> createState() => _FornecedorFormPageState();
}

class _FornecedorFormPageState extends State<FornecedorFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late MaskedTextController _cnpjController;
  bool _salvando = false;

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

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _salvando = true;
      });

      final fornecedor = {
        'nome': _nomeController.text,
        'cnpj': _cnpjController.text,
      };

      if (widget.fornecedor != null) {
        fornecedor['idFornecedor'] =
            widget.fornecedor!['idFornecedor'].toString();
      }

      try {
        await widget.onSave(fornecedor);
        Navigator.of(context).pop();
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
                    : Text(widget.fornecedor == null ? 'Cadastrar' : 'Alterar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
