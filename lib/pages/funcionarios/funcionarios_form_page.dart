import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;

class FuncionariosFormPage extends StatefulWidget {
  final Map<String, dynamic>? funcionarios;

  const FuncionariosFormPage({super.key, this.funcionarios});

  @override
  State<FuncionariosFormPage> createState() => _FuncionariosFormPageState();
}

class _FuncionariosFormPageState extends State<FuncionariosFormPage> {
  final _formKey = GlobalKey<FormState>();
  static const String apiUrl = Params.apiUrl;
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

  Future<void> _adicionarFuncionario(Map<String, dynamic> funcionarios) async {
    try {
      final response = await http
          .post(
            Uri.http(apiUrl, '/Funcionarios'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(funcionarios),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 400) {
        _mostrarErro('Erro ao adicionar funcionários: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
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
        await _adicionarFuncionario(widget.funcionarios!);
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
        title: const Text('Funcionários'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                  onFieldSubmitted: (_) => _salvar(),
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
                  onFieldSubmitted: (_) => _salvar(),
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
                  onFieldSubmitted: (_) => _salvar(),
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
                      : Text(widget.funcionarios == null
                          ? 'Cadastrar'
                          : 'Alterar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
