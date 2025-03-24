import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_mercado/pages/compras/compras_detalhes_page.dart';
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
      'dataInicio': _dataInicial?.toIso8601String(),
      'dataFim': _dataFinal?.toIso8601String(),
      'quantMinima': _quantidadeInicialController.text == ''
          ? null
          : _quantidadeInicialController.text,
      'quantMaxima': _quantidadeFinalController.text == ''
          ? null
          : _quantidadeFinalController.text,
      'idProduto': _produtoSelecionado?['idProduto'],
      'idFornecedor': _fornecedorSelecionado?['idFornecedor'],
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

  void _abrirFormularioCompra() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CompraFormPage(),
      ),
    );
    _listarCompras();
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

  void _limparFiltros() {
    setState(() {
      _produtoSelecionado = null;
      _fornecedorSelecionado = null;
      _quantidadeInicialController.clear();
      _quantidadeFinalController.clear();
      _dataInicial = null;
      _dataFinal = null;
    });
  }

  void _limparProduto() {
    setState(() {
      _produtoSelecionado = null;
    });
  }

  void _limparFornecedor() {
    setState(() {
      _fornecedorSelecionado = null;
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
      drawer: const DrawerFenomenos('Compras'),
      body: Column(
        children: [
          if (_mostrarFiltro)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Map<String, dynamic>>(
                            value: _produtoSelecionado,
                            decoration:
                                const InputDecoration(labelText: 'Produto'),
                            items: _produtos.map((produto) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: produto,
                                child: Text(
                                  produto['descricao'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _produtoSelecionado = value;
                              });
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return _produtos.map<Widget>((produto) {
                                return Text(
                                  produto['descricao'],
                                  overflow: TextOverflow.ellipsis,
                                );
                              }).toList();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _limparProduto,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Map<String, dynamic>>(
                            value: _fornecedorSelecionado,
                            decoration:
                                const InputDecoration(labelText: 'Fornecedor'),
                            items: _fornecedores.map((fornecedor) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: fornecedor,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.65,
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
                            selectedItemBuilder: (BuildContext context) {
                              return _fornecedores.map<Widget>((fornecedor) {
                                return Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.65,
                                  ),
                                  child: Text(
                                    '${fornecedor['nome']} - ${fornecedor['cnpj']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _limparFornecedor,
                        ),
                      ],
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
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(_dataInicial != null
                                ? DateFormat('dd/MM/yyyy').format(_dataInicial!)
                                : 'Data Inicial'),
                            onPressed: () => _selecionarDataInicial(context),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(_dataFinal != null
                                ? DateFormat('dd/MM/yyyy').format(_dataFinal!)
                                : 'Data Final'),
                            onPressed: () => _selecionarDataFinal(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                          ),
                          onPressed: _listarCompras,
                          child: const Text('Pesquisar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.onInverseSurface,
                          ),
                          onPressed: _limparFiltros,
                          child: const Text('Limpar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _compras.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _compras.length) {
                        return const SizedBox(height: 64);
                      }
                      final data = DateTime.parse(_compras[index]['data']);
                      final dataFormatada =
                          DateFormat('dd/MM/yyyy, HH:mm').format(data);
                      return ListTile(
                        title: Text(_compras[index]['descricaoProduto']),
                        subtitle: Text(
                            '${_compras[index]['nomeFornecedor']}\n$dataFormatada'),
                        trailing: Text('${_compras[index]['quantidade']} un.'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CompraDetalhesPage(
                                compra: _compras[index],
                              ),
                            ),
                          );
                        },
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
