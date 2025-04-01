import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ProdutosFormPage extends StatefulWidget {
  final Map<String, dynamic>? produto;

  const ProdutosFormPage({super.key, this.produto});

  @override
  State<ProdutosFormPage> createState() => _ProdutosFormPageState();
}

class _ProdutosFormPageState extends State<ProdutosFormPage> {
  static const String apiUrl = Params.apiUrl;
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
      text: widget.produto != null ? widget.produto!['codBarras'] : '',
    );
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

      if (response.statusCode >= 400) {
        _mostrarErro('Erro ao editar produto: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
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

      if (response.statusCode >= 400) {
        _mostrarErro('Erro ao adicionar produto: ${response.statusCode}');
      }
      if (response.body == '0') {
        _mostrarErro('Esse código de barras já é usado por outro produto.');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
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

      var produto = {
        'descricao': _descricaoController.text,
        'codBarras': _codbarrasController.text,
      };

      if (widget.produto != null) {
        produto['idProduto'] = widget.produto!['idProduto'].toString();
      }

      try {
        if (produto.containsKey('idProduto')) {
          await _editarProduto(produto);
        } else {
          await _adicionarProduto(produto);
        }
        if (mounted) {
          Navigator.of(context).pop(produto);
        }
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
      setState(() {
        _codbarrasController.text = codBarras;
      });
    }
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
                onFieldSubmitted: (_) => _salvar(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codbarrasController,
                      decoration:
                          const InputDecoration(labelText: 'Código de Barras'),
                      maxLength: 13,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o código de barras';
                        }
                        if (value.length < 6) {
                          return 'O código deve ter no mínimo 6 caracteres';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _salvar(),
                    ),
                  ),
                  IconButton(
                    onPressed: _consultarPorLeitor,
                    icon: const Icon(Symbols.barcode_scanner),
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
                    : Text(
                        widget.produto == null ? 'Cadastrar' : 'Alterar',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
