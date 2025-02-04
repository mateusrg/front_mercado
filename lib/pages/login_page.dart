import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarEmail,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _senhaController,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _validarSenha,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _validarLogin,
                  child: const Text('Fazer Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validarSenha(String? senha) {
    if (senha == null || senha.isEmpty) {
      return 'Digite sua senha';
    }
    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? _validarEmail(String? email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

    if (email == null || email.isEmpty) {
      return 'Digite um e-mail';
    }

    if (!emailRegex.hasMatch(email)) {
      return 'Digite um e-mail válido';
    }

    return null;
  }

  void _validarLogin() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String senha = _senhaController.text;

      print('Email: $email');
      print('Senha: $senha');

      _fazerLogin(email, senha);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Login realizado com sucesso!')),
      // );
    }
  }

  void _fazerLogin(String email, String senha) async {
    String urlBase = 'localhost:5277';
    String urlComplementar = '/Funcionarios/login';
    Uri uri = Uri.http(urlBase, urlComplementar, null);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var resposta = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'email': email,
        'senha': senha,
      }),
    );

    dynamic jsonResposta = json.decode(utf8.decode(resposta.bodyBytes));

    print(jsonResposta);
  }
}
