import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_mercado/pages/compras/compras_form.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

const String apiUrl = '${Params.ipApi}:5277';

class _ComprasPageState extends State<ComprasPage> {
  List<Map<String, dynamic>> _compras = [];
  List<Map<String, dynamic>> _produtos = [];
  List<Map<String, dynamic>> _fornecedores = [];
  final TextEditingController _pesquisaController = TextEditingController();
  final TextEditingController _quantidadeInicialController =
      TextEditingController();
  final TextEditingController _quantidadeFinalController =
      TextEditingController();
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  Map<String, dynamic>? _produtoSelecionado;
  Map<String, dynamic>? _fornecedorSelecionado;
  bool _carregando = false;
  bool _mostrarFiltro = false;

  @override
  void initState() {
    _carregarProdutosFoECompras();
    super.initState();
  }

  Future<void> _carregarProdutosFoECompras() async {
    await _carregarProdutos();
    await _carregarFornecedores();
    await _listarCompras();
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

  Future<void> _listarCompras() async {
    setState(() {
      _carregando = true;
    });

    final parametros = {
      'produto': _produtoSelecionado?['idProduto'],
      'dataInicial': _dataInicial?.toIso8601String(),
      'dataFinal': _dataFinal?.toIso8601String(),
      'fornecedor': _fornecedorSelecionado?['idFornecedor'],
      'quantidadeInicial': _quantidadeInicialController.text,
      'quantidadeFinal': _quantidadeFinalController.text,
    };

    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Compras/tudo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(parametros),
          )
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

  void _abrirFormularioCompra() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompraFormPage(
          onSave: (compra) async {
            await _adicionarCompra(compra);
          },
        ),
      ),
    );
  }

  Future<void> _selecionarDataInicial(BuildContext context) async {
    final DateTime? selecionado = await showDatePicker(
      context: context,
      initialDate: _dataInicial ?? DateTime.now(),
      firstDate: DateTime(1),
      lastDate: DateTime(9999),
      locale: const Locale('pt', 'BR'),
    );
    if (selecionado != null && selecionado != _dataInicial) {
      setState(() {
        _dataInicial = selecionado;
      });
    }
  }

  Future<void> _selecionarDataFinal(BuildContext context) async {
    final DateTime? selecionado = await showDatePicker(
      context: context,
      initialDate: _dataFinal ?? DateTime.now(),
      firstDate: DateTime(1),
      lastDate: DateTime(9999),
      locale: const Locale('pt', 'BR'),
    );
    if (selecionado != null && selecionado != _dataFinal) {
      setState(() {
        _dataFinal = selecionado;
      });
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

  void _toggleFiltro() {
    setState(() {
      _mostrarFiltro = !_mostrarFiltro;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
        actions: [
          IconButton(
            onPressed: _toggleFiltro,
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      drawer: const DrawerFenomenos(),
      body: Column(
        children: [
          if (_mostrarFiltro)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _produtoSelecionado,
                      decoration: const InputDecoration(labelText: 'Produto'),
                      items: _produtos.map((produto) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: produto,
                          child: Text(produto['descricao']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _produtoSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _fornecedorSelecionado,
                      decoration:
                          const InputDecoration(labelText: 'Fornecedor'),
                      items: _fornecedores.map((fornecedor) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: fornecedor,
                          child: Text(fornecedor['nome']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _fornecedorSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantidadeInicialController,
                            decoration: const InputDecoration(
                                labelText: 'Quantidade Inicial'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _quantidadeFinalController,
                            decoration: const InputDecoration(
                                labelText: 'Quantidade Final'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _selecionarDataInicial(context),
                            child: Text(
                              _dataInicial != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(_dataInicial!)
                                  : 'Data Inicial',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () => _selecionarDataFinal(context),
                            child: Text(
                              _dataFinal != null
                                  ? DateFormat('dd/MM/yyyy').format(_dataFinal!)
                                  : 'Data Final',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _listarCompras,
                      child: const Text('Pesquisar'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _compras.length,
                    itemBuilder: (context, index) {
                      final data = DateTime.parse(_compras[index]['data']);
                      final dataFormatada =
                          DateFormat('dd/MM/yyyy').format(data);
                      return ListTile(
                        leading: Text('${_compras[index]['quantidade']} un.'),
                        title: Text(_compras[index]['descricaoProduto']),
                        subtitle: Text(_compras[index]['nomeFornecedor']),
                        trailing: Text(dataFormatada),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioCompra,
        child: const Icon(Icons.add),
      ),
    );
  }
}
