import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/estoques/estoques_detalhes_page.dart';
import 'package:front_mercado/pages/estoques/estoques_form.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _estoques = [];
  List<Map<String, dynamic>> _tiposEstoque = [];
  String? _tipoSelecionado;
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _carregarTiposEstoqueEListar();
    super.initState();
  }

  _carregarTiposEstoqueEListar() async {
    await _carregarTiposEstoque();
    await _listarEstoques();
  }

  Future<void> _carregarTiposEstoque() async {
    try {
      final response = await http.get(
        Uri.http(apiUrl, '/TiposEstoque'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _tiposEstoque = [
            {'idTipoEstoque': null, 'descricao': 'Todos'}
          ];

          _tiposEstoque.addAll((json.decode(response.body) as List)
              .map((tipo) => {
                    'idTipoEstoque': tipo['idTipoEstoque'].toString(),
                    'descricao': tipo['descricao'],
                  })
              .toList());

          _tipoSelecionado = null;
        });
      } else {
        _mostrarErro('Erro ao carregar tipos: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Erro na conexão com a API');
    }
  }

  Future<void> _listarEstoques([String? query]) async {
    setState(() => _carregando = true);

    final Map<String, dynamic> parametros = {
      'descricaoEstoque': query,
      'idTipoEstoque': _tipoSelecionado,
    };

    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Estoques/tipo-estoque'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(parametros),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _estoques =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Falha ao carregar dados: ${response.statusCode}');
        setState(() => _carregando = false);
      }
    } catch (e) {
      _mostrarErro('Erro na conexão');
      setState(() => _carregando = false);
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

  void _abrirFormularioEstoque() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EstoquesFormPage()),
    );
    _listarEstoques();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoques'),
      ),
      drawer: const DrawerFenomenos('Estoques'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesquisaController,
                    decoration: InputDecoration(
                      labelText: 'Pesquisar',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            _listarEstoques(_pesquisaController.text),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) =>
                        _listarEstoques(_pesquisaController.text),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _tipoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Estoque',
                      border: OutlineInputBorder(),
                    ),
                    items: _tiposEstoque.map((tipo) {
                      return DropdownMenuItem<String?>(
                        value: tipo['idTipoEstoque']?.toString(),
                        child: Text(tipo['descricao']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _tipoSelecionado = value);
                      _listarEstoques(_pesquisaController.text);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _estoques.length,
                    itemBuilder: (context, index) {
                      final estoque = _estoques[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                            title: Text(estoque['descricaoEstoque']),
                            leading: Text('${estoque['idEstoque']}'),
                            trailing: Text(estoque['descricaoTipoEstoque']),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EstoqueDetalhesPage(estoque: estoque),
                                ),
                              );
                              _listarEstoques();
                            }),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioEstoque,
        child: const Icon(Icons.add),
      ),
    );
  }
}
