import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/principal_page.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';
  bool _estaCarregando = false;

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Bem-vindo ao\nFenômenos SM',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                          onFieldSubmitted: (_) =>
                              _validarLogin(), // Adicionado para executar ao pressionar Enter
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _estaCarregando ? null : _validarLogin,
                          child: _estaCarregando
                              ? const SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text('Fazer Login'),
                        ),
                        if (_mensagemErro.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _mensagemErro,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
      FocusScope.of(context).unfocus();

      String email = _emailController.text;
      String senha = _senhaController.text;

      setState(() {
        _estaCarregando = true;
      });

      _fazerLogin(email, senha);
    }
  }

  void _fazerLogin(String email, String senha) async {
    String urlBase = '${Params.ipApi}:5277';
    String urlComplementar = '/Funcionarios/login';
    Uri uri = Uri.http(urlBase, urlComplementar, null);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      var resposta = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'email': email,
              'senha': senha,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (resposta.statusCode >= 400) {
        String mensagem = utf8.decode(resposta.bodyBytes);
        setState(() {
          _mensagemErro = mensagem;
          _estaCarregando = false;
        });
        return;
      }

      dynamic jsonResposta = json.decode(utf8.decode(resposta.bodyBytes));

      setState(() {
        _mensagemErro = '';
        _estaCarregando = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuarioLogado', jsonEncode(jsonResposta));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const PrincipalPage()),
      );
    } catch (e) {
      setState(() {
        _estaCarregando = false;
      });
      _mostrarErro('Não foi possível se conectar com a API.');
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
}
