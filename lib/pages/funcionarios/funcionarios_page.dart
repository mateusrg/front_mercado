import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class FuncionariosPage extends StatefulWidget {
  const FuncionariosPage({super.key});

  @override
  State<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends State<FuncionariosPage> {
  final String apiUrl = '${Params.ipApi}:5277';
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
      final response = await http
          .get(Uri.http(
              apiUrl,
              query != null && query != ''
                  ? '/Funcionarios/IdNomeSetorEmail/$query'
                  : '/Funcionarios'))
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

  Future<void> _adicionarFuncionario(Map<String, dynamic> funcionarios) async {
    print(funcionarios);
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Funcionarios'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(funcionarios),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 400) {
        _listarFuncionarios();
      } else {
        _mostrarErro('Erro ao adicionar funcionarios: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  void _abrirFormularioFuncionarios({Map<String, dynamic>? funcionarios}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FuncionariosFormPage(
          funcionarios: funcionarios,
          onSave: (funcionarios) async {
            await _adicionarFuncionario(funcionarios);
          },
        ),
      ),
    );
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
        title: const Text('Funcionarios'),
      ),
      drawer: const DrawerFenomenos(),
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
                          leading:
                              Text('${_funcionarios[index]['idFuncionario']}'),
                          trailing: Text(_funcionarios[index]['setor'] ?? ''),
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

class FuncionariosFormPage extends StatefulWidget {
  final Map<String, dynamic>? funcionarios;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const FuncionariosFormPage(
      {super.key, this.funcionarios, required this.onSave});

  @override
  State<FuncionariosFormPage> createState() => _FuncionariosFormPageState();
}

class _FuncionariosFormPageState extends State<FuncionariosFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _setorController;
  late TextEditingController _senhaController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.funcionarios != null ? widget.funcionarios!['nome'] : '',
    );
    _emailController = TextEditingController(
      text: widget.funcionarios != null ? widget.funcionarios!['email'] : '',
    );
    _setorController = TextEditingController(
      text: widget.funcionarios != null ? widget.funcionarios!['setor'] : '',
    );
    _senhaController = TextEditingController(
      text: widget.funcionarios != null ? widget.funcionarios!['senha'] : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _setorController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _salvando = true;
      });

      final funcionario = {
        'nome': _nomeController.text,
        'email': _emailController.text,
        'setor': _setorController.text,
        'senha': _senhaController.text,
      };

      if (widget.funcionarios != null) {
        funcionario['idFuncionario'] =
            widget.funcionarios!['idFuncionario'].toString();
      }

      try {
        await widget.onSave(funcionario);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar funcionário.'),
            backgroundColor: Colors.red,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionarios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                maxLength: 100,
                validator: (String? email) {
                  final RegExp emailRegex = RegExp(
                      r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

                  if (email == null || email.isEmpty) {
                    return 'Digite um e-mail';
                  }

                  if (!emailRegex.hasMatch(email)) {
                    return 'Digite um e-mail válido';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _setorController,
                decoration: const InputDecoration(labelText: 'Setor'),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o setor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
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
                        widget.funcionarios == null ? 'Cadastrar' : 'Alterar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
