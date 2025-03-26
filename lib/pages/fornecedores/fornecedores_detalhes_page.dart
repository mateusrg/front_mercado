import 'package:flutter/material.dart';
import 'package:front_mercado/pages/fornecedores/compras_do_fornecedor_page.dart';
import 'package:front_mercado/pages/fornecedores/fornecedores_detalhes_card_page.dart';
import 'package:front_mercado/pages/fornecedores/fornecedores_form_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:front_mercado/params.dart';

class FornecedorDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> fornecedor;

  const FornecedorDetalhesPage({super.key, required this.fornecedor});

  @override
  State<FornecedorDetalhesPage> createState() => _FornecedorDetalhesPageState();
}

class _FornecedorDetalhesPageState extends State<FornecedorDetalhesPage> {
  static const String apiUrl = Params.apiUrl;
  List<dynamic> compras = [];
  bool carregandoCompras = true;

  @override
  void initState() {
    super.initState();
    carregarCompras();
  }

  Future<void> carregarCompras() async {
    final response = await http.get(Uri.http(apiUrl,
        'Fornecedores/listarComprasFornecedor/${widget.fornecedor['idFornecedor']}'));
    if (response.statusCode == 200) {
      setState(() {
        compras = json.decode(response.body);
        carregandoCompras = false;
      });
    } else {
      setState(() {
        carregandoCompras = false;
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

  Future<void> _editarFornecedor(Map<String, dynamic> fornecedor) async {
    try {
      final response = await http
          .put(
            Uri.http(apiUrl, '/Fornecedores'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(fornecedor),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro('Erro ao editar fornecedor: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioFornecedor({Map<String, dynamic>? fornecedor}) async {
    final fornecedorRecebido = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FornecedorFormPage(
          fornecedor: fornecedor,
        ),
      ),
    );

    if (fornecedorRecebido == null) return;
    if (fornecedorRecebido.containsKey('idFornecedor')) {
      await _editarFornecedor(fornecedorRecebido);
    }

    setState(() {
      widget.fornecedor['nome'] = fornecedorRecebido['nome'];
      widget.fornecedor['cnpj'] = fornecedorRecebido['cnpj'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Fornecedor'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _abrirFormularioFornecedor(fornecedor: widget.fornecedor);
        },
        child: const Icon(Icons.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FornecedoresDetalhesCardPage(
                            fornecedor: widget.fornecedor),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloFornecedoresDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.business,
                              color: Colors.cyan,
                            ),
                            title: Text('Fornecedor'),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'listTileFornecedoresDetalhesCard',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.business_outlined,
                              color: Colors.cyan.withAlpha(128),
                            ),
                            title: Text(widget.fornecedor['nome']),
                            subtitle: Text(widget.fornecedor['cnpj']),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ComprasDoFornecedorPage(compras: compras),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Hero(
                        tag: 'tituloComprasDoFornecedor',
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              Icons.shopping_cart,
                              color: Colors.green,
                            ),
                            title: Text(
                              'Compras do Fornecedor',
                            ),
                          ),
                        ),
                      ),
                      carregandoCompras
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0;
                                    i <
                                        (compras.length > 3
                                            ? 3
                                            : compras.length);
                                    i++)
                                  Hero(
                                    tag: 'listTileComprasDoFornecedor$i',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.green
                                              .withValues(alpha: 0.5),
                                        ),
                                        title: Text(
                                            compras[i]['descricaoProduto']),
                                        subtitle: Text(
                                            DateFormat('dd/MM/yyyy, HH:mm')
                                                .format(DateTime.parse(
                                                    compras[i]['data']))),
                                        trailing: Text(
                                            '${compras[i]['quantidade']} un.'),
                                      ),
                                    ),
                                  ),
                                if (compras.length > 3)
                                  ListTile(
                                    leading: Icon(
                                      Icons.add,
                                      color: Colors.grey.withValues(alpha: 0.5),
                                    ),
                                    title: const Text('E mais...'),
                                  ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
