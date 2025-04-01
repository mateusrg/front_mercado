import 'package:flutter/material.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_pesquisa_produtos.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_pesquisa_estoque_origem.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_pesquisa_estoque_destino.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_pesquisa_funcionario_solicitador.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_pesquisa_funcionario_autenticador.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/modais/dialog_verificacao_funcionario_autenticador.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class TransferenciaEstoquePage extends StatefulWidget {
  const TransferenciaEstoquePage({super.key, this.produto, this.estoque});

  final Map<String, dynamic>? produto;
  final Map<String, dynamic>? estoque;

  @override
  State<TransferenciaEstoquePage> createState() =>
      _TransferenciaEstoquePageState();
}

class _TransferenciaEstoquePageState extends State<TransferenciaEstoquePage> {
  final _formKey = GlobalKey<FormState>();
  static const String apiUrl = Params.apiUrl;
  late TextEditingController _quantidadeController;
  late TextEditingController _horaController;
  bool _salvando = false;
  bool _carregando = true;
  List<Map<String, dynamic>> _produtos = [];
  List<Map<String, dynamic>> _estoques = [];
  List<Map<String, dynamic>> _funcionarios = [];
  Map<String, dynamic>? _produtoSelecionado;
  Map<String, dynamic>? _estoqueOrigemSelecionado;
  Map<String, dynamic>? _estoqueDestinoSelecionado;
  Map<String, dynamic>? _funcionarioSolicitadorSelecionado;
  Map<String, dynamic>? _funcionarioAutenticadorSelecionado;
  DateTime? _dataSelecionada;

  @override
  void initState() {
    _quantidadeController = TextEditingController();
    _horaController =
        TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));
    _dataSelecionada = DateTime.now();
    _carregarDados();
    super.initState();
  }

  Future<void> _carregarDados() async {
    await _carregarProdutos();
    await _carregarEstoques();
    await _carregarFuncionarios();
    if (widget.produto != null) {
      final encontrado = _produtos.firstWhere(
        (p) => p['idProduto'] == widget.produto!['idProduto'],
        orElse: () => {},
      );
      _produtoSelecionado = encontrado;
    }
    if (widget.estoque != null) {
      final encontrado = _estoques.firstWhere(
        (e) => e['idEstoque'] == widget.estoque!['idEstoque'],
        orElse: () => {},
      );
      _estoqueOrigemSelecionado = encontrado;
    }
    setState(() => _carregando = false);
  }

  Future<void> _carregarProdutos() async {
    final response = await http.get(Uri.http(apiUrl, '/Produtos'));
    if (response.statusCode == 200) {
      setState(() => _produtos =
          List<Map<String, dynamic>>.from(json.decode(response.body)));
    } else {
      _mostrarErro('Erro ao carregar produtos: ${response.statusCode}');
    }
  }

  Future<void> _carregarEstoques() async {
    final response = await http.get(Uri.http(apiUrl, '/Estoques'));
    if (response.statusCode == 200) {
      setState(() => _estoques =
          List<Map<String, dynamic>>.from(json.decode(response.body)));
    } else {
      _mostrarErro('Erro ao carregar estoques: ${response.statusCode}');
    }
  }

  Future<void> _carregarFuncionarios() async {
    final response = await http.get(Uri.http(apiUrl, '/Funcionarios'));
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final usuarioLogadoString = prefs.getString('usuarioLogado');
      if (usuarioLogadoString != null) {
        final usuarioLogado = json.decode(usuarioLogadoString);
        setState(() {
          _funcionarios =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _funcionarioSolicitadorSelecionado = _funcionarios.firstWhere(
            (funcionario) =>
                funcionario['idFuncionario'] == usuarioLogado['idFuncionario'],
            orElse: () => {},
          );
        });
        if (_funcionarioSolicitadorSelecionado == {}) {
          _mostrarErro('Funcionário logado não encontrado na lista');
        }
      }
    } else {
      _mostrarErro('Erro ao carregar funcionários: ${response.statusCode}');
    }
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _salvando = true);
      try {
        final senhaValida = await showDialog<bool>(
          context: context,
          builder: (context) => DialogVerificacaoFuncionarioAutenticador(
            funcionario: _funcionarioAutenticadorSelecionado!,
          ),
        );

        if (senhaValida != true) {
          return;
        }

        final movimentacao = {
          'idProduto': _produtoSelecionado!['idProduto'],
          'quantidade': int.parse(_quantidadeController.text),
          'idEstoqueOrigem': _estoqueOrigemSelecionado!['idEstoque'],
          'idEstoqueDestino': _estoqueDestinoSelecionado!['idEstoque'],
          'idFuncionarioSolicitador':
              _funcionarioSolicitadorSelecionado!['idFuncionario'],
          'idFuncionarioAutenticador':
              _funcionarioAutenticadorSelecionado!['idFuncionario'],
          'idTipoMovimentacaoOrigem': 6,
          'idTipoMovimentacaoDestino': 7,
          'dataHora':
              '${DateFormat('yyyy-MM-dd').format(_dataSelecionada!)}T${_horaController.text}:00.000Z',
        };

        final response = await http.post(
          Uri.http(
              apiUrl, 'MovimentacoesEstoque/movimentarProdutoEntreEstoques'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(movimentacao),
        );

        if (response.statusCode == 200) {
          if (mounted) Navigator.of(context).pop();
        } else if (response.statusCode == 400) {
          _mostrarErro('Quantidade insuficiente em estoque.');
        } else {
          _mostrarErro(
              'Erro ao realizar transferência: ${response.statusCode}');
        }
      } catch (e) {
        _mostrarErro('Não foi possível se conectar com a API.');
      } finally {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? selecionado = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (selecionado != null && selecionado != _dataSelecionada) {
      setState(() => _dataSelecionada = selecionado);
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

  void _abrirDialogPesquisaProduto() async {
    final produtoSelecionado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const DialogPesquisaProduto(),
    );
    if (produtoSelecionado != null) {
      final produto = _produtos.firstWhere(
        (p) => p['idProduto'] == produtoSelecionado['idProduto'],
        orElse: () => {},
      );
      if (produto != {}) setState(() => _produtoSelecionado = produto);
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
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transferência de Estoque')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transferência de Estoque')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: _produtoSelecionado,
                        decoration: const InputDecoration(labelText: 'Produto'),
                        items: _produtos
                            .map((produto) => DropdownMenuItem(
                                  value: produto,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                                  0.8 -
                                              96,
                                    ),
                                    child: Text(
                                      '${produto['descricao']} - ${produto['codBarras']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _produtoSelecionado = value),
                        validator: (value) =>
                            value == null ? 'Selecione um produto' : null,
                      ),
                    ),
                    IconButton(
                      onPressed: _consultarPorLeitor,
                      icon: const Icon(Symbols.barcode_scanner),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _abrirDialogPesquisaProduto,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantidadeController,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira a quantidade';
                    }
                    final qtd = int.tryParse(value);
                    if (qtd == null) return 'Número inválido';
                    if (qtd <= 0) return 'Quantidade deve ser maior que zero';
                    if (qtd >= 2147483648) {
                      return 'Quantidadade deve ser menor que 2147483648';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: _estoqueOrigemSelecionado,
                        decoration:
                            const InputDecoration(labelText: 'Estoque Origem'),
                        items: _estoques
                            .map((estoque) => DropdownMenuItem(
                                  value: estoque,
                                  child: Text(estoque['descricao']),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _estoqueOrigemSelecionado = value),
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione o estoque origem';
                          }
                          if (_estoqueDestinoSelecionado != null &&
                              value['idEstoque'] ==
                                  _estoqueDestinoSelecionado!['idEstoque']) {
                            return 'Estoques devem ser diferentes';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final estoque = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) =>
                              const DialogPesquisaEstoqueOrigem(),
                        );
                        if (estoque != null) {
                          final encontrado = _estoques.firstWhere(
                            (e) => e['idEstoque'] == estoque['idEstoque'],
                            orElse: () => {},
                          );
                          if (encontrado != {}) {
                            setState(
                                () => _estoqueOrigemSelecionado = encontrado);
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: _estoqueDestinoSelecionado,
                        decoration:
                            const InputDecoration(labelText: 'Estoque Destino'),
                        items: _estoques
                            .map((estoque) => DropdownMenuItem(
                                  value: estoque,
                                  child: Text(estoque['descricao']),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _estoqueDestinoSelecionado = value),
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione o estoque destino';
                          }
                          if (_estoqueOrigemSelecionado != null &&
                              value['idEstoque'] ==
                                  _estoqueOrigemSelecionado!['idEstoque']) {
                            return 'Estoques devem ser diferentes';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final estoque = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) =>
                              const DialogPesquisaEstoqueDestino(),
                        );
                        if (estoque != null) {
                          final encontrado = _estoques.firstWhere(
                            (e) => e['idEstoque'] == estoque['idEstoque'],
                            orElse: () => {},
                          );
                          if (encontrado != {}) {
                            setState(
                                () => _estoqueDestinoSelecionado = encontrado);
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: _funcionarioSolicitadorSelecionado,
                        decoration: const InputDecoration(
                            labelText: 'Funcionário Solicitador'),
                        items: _funcionarios
                            .map((funcionario) => DropdownMenuItem(
                                  value: funcionario,
                                  child: Text(funcionario['nome']),
                                ))
                            .toList(),
                        onChanged: (value) => setState(
                            () => _funcionarioSolicitadorSelecionado = value),
                        validator: (value) =>
                            value == null ? 'Selecione o solicitador' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final funcionario =
                            await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) =>
                              const DialogPesquisaFuncionarioSolicitador(),
                        );
                        if (funcionario != null) {
                          final encontrado = _funcionarios.firstWhere(
                            (f) =>
                                f['idFuncionario'] ==
                                funcionario['idFuncionario'],
                            orElse: () => {},
                          );
                          if (encontrado != {}) {
                            setState(() => _funcionarioSolicitadorSelecionado =
                                encontrado);
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: _funcionarioAutenticadorSelecionado,
                        decoration: const InputDecoration(
                            labelText: 'Funcionário Autenticador'),
                        items: _funcionarios
                            .map((funcionario) => DropdownMenuItem(
                                  value: funcionario,
                                  child: Text(funcionario['nome']),
                                ))
                            .toList(),
                        onChanged: (value) => setState(
                            () => _funcionarioAutenticadorSelecionado = value),
                        validator: (value) =>
                            value == null ? 'Selecione o autenticador' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final funcionario =
                            await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) =>
                              const DialogPesquisaFuncionarioAutenticador(),
                        );
                        if (funcionario != null) {
                          final encontrado = _funcionarios.firstWhere(
                            (f) =>
                                f['idFuncionario'] ==
                                funcionario['idFuncionario'],
                            orElse: () => {},
                          );
                          if (encontrado != {}) {
                            setState(() => _funcionarioAutenticadorSelecionado =
                                encontrado);
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                            DateFormat('dd/MM/yyyy').format(_dataSelecionada!)),
                        onPressed: () => _selecionarData(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _horaController,
                        decoration: const InputDecoration(labelText: 'Hora'),
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text =
                                newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                            final buffer = StringBuffer();
                            for (int i = 0; i < text.length; i++) {
                              if (i == 2) buffer.write(':');
                              if (i >= 4) break;
                              buffer.write(text[i]);
                            }
                            return TextEditingValue(
                              text: buffer.toString(),
                              selection: TextSelection.collapsed(
                                  offset: buffer.length),
                            );
                          }),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira a hora';
                          }
                          if (value.length != 5) return 'Horário inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
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
                      : const Text(
                          'Transferir',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
