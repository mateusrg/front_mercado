import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

final String apiUrl = '${Params.ipApi}:5277';

class _ComprasPageState extends State<ComprasPage> {
  List<Map<String, dynamic>> _compras = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarCompras();
    super.initState();
  }

  Future<void> _listarCompras([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = await http
          .get(Uri.http(apiUrl, '/Compras/informacoes'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _compras =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar compras: ${response.statusCode}');
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

  Future<void> _adicionarCompra(Map<String, dynamic> compra) async {
    print(compra);
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Compras'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(compra),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarCompras();
      } else {
        _mostrarErro('Erro ao adicionar compra: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _editarCompra(Map<String, dynamic> compra) async {
    try {
      final response = await http
          .put(
            Uri.http(apiUrl, '/Compras'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(compra),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarCompras();
      } else {
        _mostrarErro('Erro ao editar compra: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioCompra({Map<String, dynamic>? compra}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompraFormPage(
          compra: compra,
          onSave: (compra) async {
            if (compra.containsKey('idCompra')) {
              await _editarCompra(compra);
            } else {
              await _adicionarCompra(compra);
            }
          },
        ),
      ),
    );
  }

  void _pesquisarCompras() {
    _listarCompras(_pesquisaController.text);
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
        title: const Text('Compras'),
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
                  onPressed: _pesquisarCompras,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _compras.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Text('${_compras[index]['quantidade']} un.'),
                        title: Text(_compras[index]['produto']),
                        subtitle: Text(_compras[index]['fornecedor']),
                        trailing: Text('${_compras[index]['data']}'),
                        onTap: () =>
                            _abrirFormularioCompra(compra: _compras[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioCompra(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CompraFormPage extends StatefulWidget {
  final Map<String, dynamic>? compra;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const CompraFormPage({super.key, this.compra, required this.onSave});

  @override
  State<CompraFormPage> createState() => _CompraFormPageState();
}

class _CompraFormPageState extends State<CompraFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantidadeController;
  bool _salvando = false;
  DateTime? _dataSelecionada;
  List<Map<String, dynamic>> _fornecedores = [];
  List<Map<String, dynamic>> _produtos = [];
  Map<String, dynamic>? _fornecedorSelecionado;
  Map<String, dynamic>? _produtoSelecionado;

  @override
  void initState() {
    super.initState();
    _quantidadeController = TextEditingController(
      text: widget.compra != null ? '${widget.compra!['quantidade']}' : '',
    );
    if (widget.compra != null && widget.compra!['data'] != null) {
      _dataSelecionada = DateFormat('dd/MM/yyyy').parse(widget.compra!['data']);
    }
    _carregarFornecedoresEProdutos();
  }

  Future<void> _carregarFornecedores() async {
    final response = await http.get(Uri.http(apiUrl, '/Fornecedores'));
    if (response.statusCode == 200) {
      setState(() {
        _fornecedores =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        if (widget.compra != null) {
          _fornecedorSelecionado = _fornecedores.firstWhere(
              (fornecedor) =>
                  fornecedor['idFornecedor'] == widget.compra!['idFornecedor'],
              orElse: () => {});
        }
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
        if (widget.compra != null) {
          _produtoSelecionado = _produtos.firstWhere(
              (produto) => produto['idProduto'] == widget.compra!['idProduto'],
              orElse: () => {});
        }
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

      if (widget.compra != null) {
        compra['idCompra'] = widget.compra!['idCompra'].toString();
      }

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
                    : Text(widget.compra == null ? 'Cadastrar' : 'Alterar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _carregarFornecedoresEProdutos() async {
    await _carregarFornecedores();
    _carregarProdutos();
  }
}
