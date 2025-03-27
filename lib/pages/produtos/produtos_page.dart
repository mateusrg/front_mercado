import 'package:flutter/material.dart';
import 'package:front_mercado/pages/produtos/produtos_detalhes_page.dart';
import 'package:front_mercado/pages/produtos/produtos_form_page.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:material_symbols_icons/symbols.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  static const String apiUrl = Params.apiUrl;
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
      final response = query != null && query != ''
          ? await http
              .post(
                Uri.http(apiUrl, '/Produtos/descricaoECodBarras'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({'query': query}),
              )
              .timeout(const Duration(seconds: 15))
          : await http
              .get(
                Uri.http(apiUrl, '/Produtos'),
              )
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

  void _abrirFormularioProduto({Map<String, dynamic>? produto}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProdutosFormPage(produto: produto),
      ),
    );
    _listarProdutos();
  }

  void _pesquisarProdutos() {
    _listarProdutos(_pesquisaController.text);
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
      delayMillis: 500,
      cameraFace: CameraFace.back,
      cancelButtonText: 'Cancelar',
    );

    return res != null && res.length > 5 ? res : null;
  }

  _consultarPorLeitor() async {
    final codBarras = await _lerCodigoDeBarras();
    if (codBarras != null) {
      _listarProdutos(codBarras);
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
              Icons.shopping_bag,
              color: Colors.green,
            ),
            SizedBox(width: 12),
            Text(
              'Produtos',
              style: TextStyle(fontSize: 22),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      drawer: const DrawerFenomenos('Produtos'),
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
                    onSubmitted: (_) => _pesquisarProdutos(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.barcode_scanner),
                  onPressed: _consultarPorLeitor,
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
                        leading: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.green.withAlpha(128),
                        ),
                        title: Text(_produtos[index]['descricao']),
                        subtitle: Text(_produtos[index]['codBarras']),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProdutosDetalhesPage(
                                produto: _produtos[index],
                              ),
                            ),
                          );
                          _listarProdutos();
                        },
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
