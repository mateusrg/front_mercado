import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class TiposEstoquePage extends StatefulWidget {
  const TiposEstoquePage({super.key});

  @override
  State<TiposEstoquePage> createState() => _TiposEstoquePageState();
}

class _TiposEstoquePageState extends State<TiposEstoquePage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _tiposEstoque = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarTiposEstoque();
    super.initState();
  }

  Future<void> _listarTiposEstoque([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .get(Uri.http(
              apiUrl,
              query != null && query != ''
                  ? '/TiposEstoque/descricao/$query'
                  : '/TiposEstoque'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _tiposEstoque =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar tipos de estoque: ${response.statusCode}');
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

      if (response.statusCode < 400) {
        _listarTiposEstoque();
      } else {
        _mostrarErro('Erro ao adicionar tipo de estoque: ${response.statusCode}');
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

      if (response.statusCode < 400) {
        _listarTiposEstoque();
      } else {
        _mostrarErro('Erro ao editar tipo de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioTipoEstoque({Map<String, dynamic>? tipoEstoque}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TipoEstoqueFormPage(
          tipoEstoque: tipoEstoque,
          onSave: (tipoEstoque) async {
            if (tipoEstoque['idTipoEstoque'] != null) {
              await _editarTipoEstoque(tipoEstoque);
            } else {
              await _adicionarTipoEstoque(tipoEstoque);
            }
          },
        ),
      ),
    );
  }

  void _pesquisarTiposEstoque() {
    _listarTiposEstoque(_pesquisaController.text);
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
        title: const Text('Tipos Estoque'),
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
                  onPressed: _pesquisarTiposEstoque,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tiposEstoque.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_tiposEstoque[index]['descricao']),
                        onTap: () => _abrirFormularioTipoEstoque(
                            tipoEstoque: _tiposEstoque[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioTipoEstoque(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TipoEstoqueFormPage extends StatefulWidget {
  final Map<String, dynamic>? tipoEstoque;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const TipoEstoqueFormPage({super.key, this.tipoEstoque, required this.onSave});

  @override
  State<TipoEstoqueFormPage> createState() => _TipoEstoqueFormPageState();
}

class _TipoEstoqueFormPageState extends State<TipoEstoqueFormPage> {
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

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _salvando = true;
      });

      await widget.onSave({
        'idTipoEstoque': widget.tipoEstoque?['idTipoEstoque'],
        'descricao': _descricaoController.text,
      });

      setState(() {
        _salvando = false;
      });

      Navigator.of(context).pop();
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
              ),
              const SizedBox(height: 16.0),
              _salvando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _salvar,
                      child: Text(widget.tipoEstoque == null ? 'Cadastrar' : 'Alterar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}