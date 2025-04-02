import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_pesquisa_estoque.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_pesquisa_produtos.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_pesquisa_tipo_movimentacao_estoque.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_descarte.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_transferencia.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_vendas.dart';
import 'package:front_mercado/pages/compras/compras_form.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import 'movimentacao_estoque_detalhes_page.dart';

class MovimentacoesEstoquePage extends StatefulWidget {
  const MovimentacoesEstoquePage({super.key});

  @override
  State<MovimentacoesEstoquePage> createState() =>
      _MovimentacoesEstoquePageState();
}

class _MovimentacoesEstoquePageState extends State<MovimentacoesEstoquePage> {
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _movimentacoes = [];
  List<Map<String, dynamic>> _produtos = [];
  List<Map<String, dynamic>> _estoques = [];
  List<Map<String, dynamic>> _tiposMovimentacaoEstoque = [];
  bool _carregando = true;
  bool _mostrarFiltro = false;

  Map<String, dynamic>? _produtoSelecionado;
  Map<String, dynamic>? _estoqueSelecionado;
  Map<String, dynamic>? _tipoMovimentacaoEstoqueSelecionado;
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  final TextEditingController _quantidadeInicialController =
      TextEditingController();
  final TextEditingController _quantidadeFinalController =
      TextEditingController();

  @override
  void initState() {
    _carregarDadosIniciais();
    super.initState();
  }

  Future<void> _carregarDadosIniciais() async {
    await _carregarProdutos();
    await _carregarEstoques();
    await _carregarTiposEstoque();
    await _listarMovimentacoes();
  }

  Future<void> _carregarProdutos() async {
    final response = await http.get(Uri.http(apiUrl, '/Produtos'));
    if (response.statusCode == 200) {
      setState(() {
        _produtos = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  Future<void> _carregarEstoques() async {
    final response = await http.get(Uri.http(apiUrl, '/Estoques'));
    if (response.statusCode == 200) {
      setState(() {
        _estoques = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  Future<void> _carregarTiposEstoque() async {
    final response =
        await http.get(Uri.http(apiUrl, '/TiposMovimentacaoEstoque'));
    if (response.statusCode == 200) {
      setState(() {
        _tiposMovimentacaoEstoque =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  Future<void> _listarMovimentacoes() async {
    setState(() {
      _carregando = true;
    });

    final parametros = {
      'dataInicio': _dataInicial?.toIso8601String(),
      'dataFim': _dataFinal?.toIso8601String(),
      'quantidadeMinima': _quantidadeInicialController.text.isEmpty
          ? null
          : _quantidadeInicialController.text,
      'quantidadeMaxima': _quantidadeFinalController.text.isEmpty
          ? null
          : _quantidadeFinalController.text,
      'idProduto': _produtoSelecionado?['idProduto'],
      'idEstoque': _estoqueSelecionado?['idEstoque'],
      'idTipoMovimentacaoEstoque':
          _tipoMovimentacaoEstoqueSelecionado?['idTipoMovimentacaoEstoque']
    };

    try {
      final response = await http.post(
        Uri.http(apiUrl, '/MovimentacoesEstoque/filtrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parametros),
      );

      if (response.statusCode == 200) {
        setState(() {
          _movimentacoes =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _mostrarErro('Erro ao listar movimentações: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _mostrarErro(String mensagem) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {}
  }

  void _abrirFormularioVenda() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VendaPage(),
      ),
    );
    _listarMovimentacoes();
  }

  void _abrirFormularioTransferencia() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TransferenciaEstoquePage(),
      ),
    );
    _listarMovimentacoes();
  }

  void _abrirFormularioCompras() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CompraFormPage(),
      ),
    );
    _listarMovimentacoes();
  }

  void _abrirFormularioDescarte() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DescartePage(),
      ),
    );
    _listarMovimentacoes();
  }

  void _toggleFiltro() {
    setState(() {
      _mostrarFiltro = !_mostrarFiltro;
    });
  }

  void _limparFiltros() {
    setState(() {
      _produtoSelecionado = null;
      _estoqueSelecionado = null;
      _tipoMovimentacaoEstoqueSelecionado = null;
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

  void _limparEstoque() {
    setState(() {
      _estoqueSelecionado = null;
    });
  }

  void _limparTipoMovimentacao() {
    setState(() {
      _tipoMovimentacaoEstoqueSelecionado = null;
    });
  }

  Future<void> _selecionarDataInicial(BuildContext context) async {
    final DateTime? selecionado = await showDatePicker(
      context: context,
      initialDate: _dataInicial ?? DateTime.now(),
      firstDate: DateTime(1),
      lastDate: DateTime(9999),
    );
    if (selecionado != null) {
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
    );
    if (selecionado != null) {
      setState(() {
        _dataFinal = selecionado;
      });
    }
  }

  Future<String?> _lerCodigoDeBarras() async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Ler Código de Barras',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
      cancelButtonText: 'Cancelar',
    );

    return res != null && res.length > 5 ? res : null;
  }

  _consultarPorLeitor() async {
    final codBarras = await _lerCodigoDeBarras();
    if (codBarras != null) {
      final encontrado = _produtos.firstWhere(
        (p) => p['codBarras'] == codBarras,
        orElse: () => {},
      );
      if (encontrado.isNotEmpty) {
        setState(() => _produtoSelecionado = encontrado);
      } else {
        _mostrarErro('Produto não encontrado.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forklift,
              color: Colors.blue,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Movimentações de Estoque',
                style: TextStyle(fontSize: 22),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleFiltro,
            icon:
                Icon(_mostrarFiltro ? Icons.filter_alt_off : Icons.filter_alt),
          ),
        ],
      ),
      drawer: const DrawerFenomenos('Movimentações de Estoque'),
      body: Column(
        children: [
          if (_mostrarFiltro)
            Card(
              margin: const EdgeInsets.fromLTRB(8, 2, 8, 4),
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
                              return DropdownMenuItem(
                                value: produto,
                                child: Text(produto['descricao']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _produtoSelecionado = value;
                              });
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return _produtos.map<Widget>((produto) {
                                return Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                                0.65 -
                                            48,
                                  ),
                                  child: Text(
                                    produto['descricao'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: _consultarPorLeitor,
                          icon: const Icon(Symbols.barcode_scanner),
                        ),
                        if (_produtoSelecionado == null)
                          IconButton(
                            onPressed: () async {
                              final produto =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) =>
                                    const DialogPesquisaProduto(),
                              );
                              if (produto != null) {
                                final encontrado = _produtos.firstWhere(
                                  (p) => p['idProduto'] == produto['idProduto'],
                                  orElse: () => {},
                                );
                                if (encontrado != {}) {
                                  setState(
                                      () => _produtoSelecionado = encontrado);
                                }
                              }
                            },
                            icon: const Icon(Icons.search),
                          ),
                        if (_produtoSelecionado != null)
                          IconButton(
                            onPressed: _limparProduto,
                            icon: const Icon(Icons.clear),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Map<String, dynamic>>(
                            value: _estoqueSelecionado,
                            decoration:
                                const InputDecoration(labelText: 'Estoque'),
                            items: _estoques.map((estoque) {
                              return DropdownMenuItem(
                                value: estoque,
                                child: Text(estoque['descricao']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _estoqueSelecionado = value;
                              });
                            },
                          ),
                        ),
                        if (_estoqueSelecionado == null)
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () async {
                              final estoque =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) =>
                                    const DialogPesquisaEstoque(),
                              );
                              if (estoque != null) {
                                final encontrado = _estoques.firstWhere(
                                  (e) => e['idEstoque'] == estoque['idEstoque'],
                                  orElse: () => {},
                                );
                                if (encontrado != {}) {
                                  setState(
                                      () => _estoqueSelecionado = encontrado);
                                }
                              }
                            },
                          ),
                        if (_estoqueSelecionado != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _limparEstoque,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Map<String, dynamic>>(
                            value: _tipoMovimentacaoEstoqueSelecionado,
                            decoration: const InputDecoration(
                                labelText: 'Tipo de Movimentação'),
                            items: _tiposMovimentacaoEstoque.map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo['descricao']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _tipoMovimentacaoEstoqueSelecionado = value;
                              });
                            },
                          ),
                        ),
                        if (_tipoMovimentacaoEstoqueSelecionado == null)
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () async {
                              final tipo =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) =>
                                    const DialogPesquisaTipoMovimentacaoEstoque(),
                              );
                              if (tipo != null) {
                                final encontrado =
                                    _tiposMovimentacaoEstoque.firstWhere(
                                  (t) =>
                                      t['idTipoMovimentacaoEstoque'] ==
                                      tipo['idTipoMovimentacaoEstoque'],
                                  orElse: () => {},
                                );
                                if (encontrado != {}) {
                                  setState(() =>
                                      _tipoMovimentacaoEstoqueSelecionado =
                                          encontrado);
                                }
                              }
                            },
                          ),
                        if (_tipoMovimentacaoEstoqueSelecionado != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _limparTipoMovimentacao,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_dataInicial != null
                                ? DateFormat('dd/MM/yyyy').format(_dataInicial!)
                                : 'Data Inicial'),
                            onPressed: () => _selecionarDataInicial(context),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_dataFinal != null
                                ? DateFormat('dd/MM/yyyy').format(_dataFinal!)
                                : 'Data Final'),
                            onPressed: () => _selecionarDataFinal(context),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantidadeInicialController,
                            decoration: const InputDecoration(
                                labelText: 'Quantidade Inicial'),
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true, decimal: false),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^-?(0|[1-9]\d*)?$'),
                              ),
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
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _listarMovimentacoes,
                          child: const Text('Pesquisar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
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
                : _movimentacoes.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24.0),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                'Nenhuma movimentação encontrada.',
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _movimentacoes.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _movimentacoes.length) {
                            return const ListTile();
                          }
                          final movimentacao = _movimentacoes[index];
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovimentacaoDetalhesPage(
                                    movimentacao: movimentacao,
                                  ),
                                ),
                              );
                            },
                            title: Text(movimentacao['descricaoProduto']),
                            subtitle:
                                Text('${movimentacao['descricaoEstoque']}'),
                            leading: Text(
                              '${movimentacao['quantidade'] >= 0 ? '+' : '-'}${movimentacao['quantidade'].abs()}',
                              style: TextStyle(
                                color: movimentacao['quantidade'] >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            trailing: Text(
                                '${movimentacao['descricaoMovimentacaoEstoque']}\n${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.parse(movimentacao['dataHora']))}'),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.red,
        activeForegroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.shopping_cart),
            backgroundColor: const Color.fromARGB(255, 0, 156, 59),
            label: 'Vender',
            onTap: _abrirFormularioVenda,
          ),
          SpeedDialChild(
            child: const Icon(Icons.swap_horiz),
            backgroundColor: const Color.fromARGB(255, 240, 222, 57),
            label: 'Transferir de Estoque',
            onTap: _abrirFormularioTransferencia,
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_shopping_cart),
            backgroundColor: const Color.fromARGB(255, 0, 39, 118),
            label: 'Cadastrar Compra',
            onTap: _abrirFormularioCompras,
          ),
          SpeedDialChild(
            child: const Icon(Icons.delete),
            backgroundColor: const Color.fromARGB(255, 0, 134, 151),
            label: 'Descartar',
            onTap: _abrirFormularioDescarte,
          )
        ],
      ),
    );
  }
}
