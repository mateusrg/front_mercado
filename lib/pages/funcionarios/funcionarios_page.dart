import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_detalhes_page.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_form_page.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class FuncionariosPage extends StatefulWidget {
  const FuncionariosPage({super.key});

  @override
  State<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends State<FuncionariosPage> {
  static const String apiUrl = Params.apiUrl;
  List<Map<String, dynamic>> _funcionarios = [];
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    _listarFuncionarios();
    super.initState();
  }

  Future<void> _listarFuncionarios([String? query]) async {
    setState(() {
      _carregando = true;
    });

    try {
      final response = query != null && query != ''
          ? await http
              .post(Uri.http(apiUrl, '/Funcionarios/IdNomeSetorEmail'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({'query': query}))
              .timeout(const Duration(seconds: 15))
          : await http
              .get(Uri.http(apiUrl, '/Funcionarios'))
              .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        setState(() {
          _funcionarios =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _carregando = false;
        });
      } else {
        _mostrarErro('Erro ao listar funcionarios: ${response.statusCode}');
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

  void _abrirFormularioFuncionarios(
      {Map<String, dynamic>? funcionarios}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FuncionariosFormPage(funcionarios: funcionarios),
      ),
    );
    _listarFuncionarios();
  }

  void _pesquisarFuncionarios() {
    _listarFuncionarios(_pesquisaController.text);
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group,
              color: Colors.yellow,
            ),
            SizedBox(width: 12),
            Text(
              'Funcionários',
              style: TextStyle(fontSize: 22),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      drawer: const DrawerFenomenos('Funcionarios'),
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
                    onSubmitted: (_) => _pesquisarFuncionarios(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _pesquisarFuncionarios,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _funcionarios.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(_funcionarios[index]['nome']),
                          subtitle: Text(_funcionarios[index]['email']),
                          leading: Icon(
                            Icons.group_outlined,
                            color: Colors.yellow.withAlpha(128),
                          ),
                          trailing: Text(_funcionarios[index]['setor'] ?? ''),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FuncionariosDetalhesPage(
                                  funcionario: _funcionarios[index],
                                ),
                              ),
                            );
                            _listarFuncionarios();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioFuncionarios(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
