import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class TiposMovimentacoesEstoquePage extends StatefulWidget {
  const TiposMovimentacoesEstoquePage({super.key});

  @override
  State<TiposMovimentacoesEstoquePage> createState() => _TiposMovimentacoesEstoquePageState();
}

class _TiposMovimentacoesEstoquePageState extends State<TiposMovimentacoesEstoquePage> {
  final String apiUrl = '${Params.ipApi}:5277';
  List<Map<String, dynamic>> _tiposMovimentacoesEstoque = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarTiposMovimentacoesEstoque();
    super.initState();
  }

  Future<void> _listarTiposMovimentacoesEstoque([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .get(Uri.http(
              apiUrl,
              query != null && query != ''
                  ? '/TiposMovimentacaoEstoque/descricao/$query'
                  : '/TiposMovimentacaoEstoque'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _tiposMovimentacoesEstoque =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar tipos de movimentações de estoque: ${response.statusCode}');
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

  Future<void> _adicionarTipoMovimentacaoEstoque(Map<String, dynamic> tipoMovimentacaoEstoque) async {
    try {
      tipoMovimentacaoEstoque['idTipoMovimentacaoEstoque'] = 0;
      final response = await http
          .post(
            Uri.http(apiUrl, '/TiposMovimentacaoEstoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(tipoMovimentacaoEstoque),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarTiposMovimentacoesEstoque();
      } else {
        _mostrarErro('Erro ao adicionar tipo de movimentação de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _editarTipoMovimentacaoEstoque(Map<String, dynamic> tipoMovimentacaoEstoque) async {
    try {
      final response = await http
          .put(
            Uri.http(apiUrl, '/TiposMovimentacaoEstoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(tipoMovimentacaoEstoque),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarTiposMovimentacoesEstoque();
      } else {
        _mostrarErro('Erro ao editar tipo de movimentação de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioTipoMovimentacaoEstoque({Map<String, dynamic>? tipoMovimentacaoEstoque}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TipoMovimentacaoEstoqueFormPage(
          tipoMovimentacaoEstoque: tipoMovimentacaoEstoque,
          onSave: (tipoMovimentacaoEstoque) async {
            if (tipoMovimentacaoEstoque['idTipoMovimentacaoEstoque'] != null) {
              await _editarTipoMovimentacaoEstoque(tipoMovimentacaoEstoque);
            } else {
              await _adicionarTipoMovimentacaoEstoque(tipoMovimentacaoEstoque);
            }
          },
        ),
      ),
    );
  }

  void _pesquisarTiposMovimentacoesEstoque() {
    _listarTiposMovimentacoesEstoque(_pesquisaController.text);
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
        title: const Text('Tipos Movimentações Estoque'),
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
                  onPressed: _pesquisarTiposMovimentacoesEstoque,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tiposMovimentacoesEstoque.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_tiposMovimentacoesEstoque[index]['descricao']),
                        onTap: () => _abrirFormularioTipoMovimentacaoEstoque(
                            tipoMovimentacaoEstoque: _tiposMovimentacoesEstoque[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioTipoMovimentacaoEstoque(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TipoMovimentacaoEstoqueFormPage extends StatefulWidget {
  final Map<String, dynamic>? tipoMovimentacaoEstoque;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const TipoMovimentacaoEstoqueFormPage({super.key, this.tipoMovimentacaoEstoque, required this.onSave});

  @override
  State<TipoMovimentacaoEstoqueFormPage> createState() => _TipoMovimentacaoEstoqueFormPageState();
}

class _TipoMovimentacaoEstoqueFormPageState extends State<TipoMovimentacaoEstoqueFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(
      text: widget.tipoMovimentacaoEstoque != null ? widget.tipoMovimentacaoEstoque!['descricao'] : '',
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
        'idTipoMovimentacaoEstoque': widget.tipoMovimentacaoEstoque?['idTipoMovimentacaoEstoque'],
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
        title: const Text('Tipo Movimentação Estoque'),
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
                      child: Text(widget.tipoMovimentacaoEstoque == null ? 'Cadastrar' : 'Alterar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
