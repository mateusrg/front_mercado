import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final String apiUrl = '${Params.ipApi}:48712';
  List<Map<String, dynamic>> _produtos = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarProdutos();
    super.initState();
  }

  Future<void> _listarProdutos([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .get(Uri.http(
              apiUrl,
              query != null && query != ''
                  ? '/Produtos/descricaoECodBarras/$query'
                  : '/Produtos'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _produtos =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar produtos: ${response.statusCode}');
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

  Future<void> _adicionarProduto(Map<String, dynamic> produto) async {
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Produtos'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(produto),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarProdutos();
      } else {
        _mostrarErro('Erro ao adicionar produto: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
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

      if (response.statusCode < 400) {
        _listarProdutos();
      } else {
        _mostrarErro('Erro ao editar fornecedor: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioProduto({Map<String, dynamic>? produto}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProdutosFormPage(
          produto: produto,
          onSave: (produto) async {
            if (produto.containsKey('IdProduto')) {
              await _editarProduto(produto);
            } else {
              await _adicionarProduto(produto);
            }
          },
        ),
      ),
    );
  }

  void _pesquisarProdutos() {
    _listarProdutos(_pesquisaController.text);
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
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
                  onPressed: _pesquisarProdutos,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _produtos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_produtos[index]['descricao']),
                        subtitle: Text(_produtos[index]['codBarras']),
                        onTap: () =>
                            _abrirFormularioProduto(produto: _produtos[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioProduto(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProdutosFormPage extends StatefulWidget {
  final Map<String, dynamic>? produto;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const ProdutosFormPage({super.key, this.produto, required this.onSave});

  @override
  State<ProdutosFormPage> createState() => _ProdutosFormPageState();
}

class _ProdutosFormPageState extends State<ProdutosFormPage> {
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
      text: widget.produto != null ? widget.produto!['codbarras'] : '',
    );
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

      final produto = {
        'descricao': _descricaoController.text,
        'codbarras': _codbarrasController.text,
      };

      if (widget.produto != null) {
        produto['idProduto'] = widget.produto!['idProduto'].toString();
      }

      try {
        await widget.onSave(produto);
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
