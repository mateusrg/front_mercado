import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_mercado/pages/compras/modais/dialog_pesquisa_fornecedor.dart';
import 'package:front_mercado/pages/compras/modais/dialog_pesquisa_produtos.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:convert';

import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class CompraFormPage extends StatefulWidget {
  const CompraFormPage({super.key});

  @override
  State<CompraFormPage> createState() => _CompraFormPageState();
}

class _CompraFormPageState extends State<CompraFormPage> {
  final _formKey = GlobalKey<FormState>();
  static const String apiUrl = Params.apiUrl;
  late TextEditingController _quantidadeController;
  late TextEditingController _horaController;
  bool _salvando = false;
  bool _carregando = true;
  DateTime? _dataSelecionada;
  List<Map<String, dynamic>> _fornecedores = [];
  List<Map<String, dynamic>> _produtos = [];
  Map<String, dynamic>? _fornecedorSelecionado;
  Map<String, dynamic>? _produtoSelecionado;

  @override
  void initState() {
    super.initState();
    _horaController =
        TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));
    _dataSelecionada = DateTime.now();
    _quantidadeController = TextEditingController();
    _carregarFornecedoresEProdutos();
  }

  Future<void> _carregarFornecedoresEProdutos() async {
    await _carregarFornecedores();
    await _carregarProdutos();
    setState(() => _carregando = false);
  }

  Future<void> _carregarFornecedores() async {
    final response = await http.get(Uri.http(apiUrl, '/Fornecedores'));
    if (response.statusCode == 200) {
      setState(() => _fornecedores =
          List<Map<String, dynamic>>.from(json.decode(response.body)));
    } else {
      _mostrarErro('Erro ao carregar fornecedores: ${response.statusCode}');
    }
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

      final DateTime dataHora = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        int.parse(_horaController.text.split(':')[0]),
        int.parse(_horaController.text.split(':')[1]),
      );

      final compra = {
        'idFornecedor': _fornecedorSelecionado!['idFornecedor'],
        'idProduto': _produtoSelecionado!['idProduto'],
        'data': dataHora.toIso8601String(),
        'quantidade': _quantidadeController.text,
        'idFuncionarioSolicitador': 1,
        'idFuncionarioAutenticador': 2,
      };

      try {
        await _adicionarCompra(compra);
        if (mounted) {
          Navigator.of(context).pop();
        }
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
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {}
  }

  Future<void> _adicionarCompra(Map<String, dynamic> compra) async {
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, 'Compras/Compra'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(compra),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro('Erro ao adicionar compra: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
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
        appBar: AppBar(
          title: const Row(children: [
            SizedBox(width: 12),
            Text('Comprar'),
          ]),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          SizedBox(width: 12),
          Text('Comprar'),
        ]),
      ),
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
                        value: _fornecedorSelecionado,
                        decoration:
                            const InputDecoration(labelText: 'Fornecedor'),
                        items: _fornecedores
                            .map((fornecedor) => DropdownMenuItem(
                                  value: fornecedor,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                                  0.8 -
                                              32,
                                    ),
                                    child: Text(
                                      '${fornecedor['nome']} - ${fornecedor['cnpj']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _fornecedorSelecionado = value),
                        validator: (value) =>
                            value == null ? 'Selecione um fornecedor' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final fornecedor =
                            await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) =>
                              const DialogPesquisaFornecedores(),
                        );
                        if (fornecedor != null) {
                          final encontrado = _fornecedores.firstWhere(
                            (f) =>
                                f['idFornecedor'] == fornecedor['idFornecedor'],
                            orElse: () => {},
                          );
                          if (encontrado != {}) {
                            setState(() => _fornecedorSelecionado = encontrado);
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      onPressed: () async {
                        final produto = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => const DialogPesquisaProduto(),
                        );
                        if (produto != null) {
                          final encontrado = _produtos.firstWhere(
                            (p) => p['idProduto'] == produto['idProduto'],
                            orElse: () => {},
                          );
                          if (encontrado != {}) {
                            setState(() => _produtoSelecionado = encontrado);
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
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
                      : const Text('Comprar', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
