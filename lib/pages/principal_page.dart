import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front_mercado/pages/login_page.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_page.dart';
import 'package:front_mercado/pages/produtos/produtos_page.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  _PrincipalPageState createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _deslogar(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioLogado');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Você realmente deseja sair?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deslogar(context);
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _informacoesUsuarioLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonInformacoesUsuarioLogado = prefs.getString('usuarioLogado');
    if (jsonInformacoesUsuarioLogado != null) {
      return jsonDecode(jsonInformacoesUsuarioLogado);
    }
    return null;
  }

  void _editarFuncionario(BuildContext context, Map<String, dynamic> userInfo) {
  final TextEditingController nomeController = TextEditingController(text: userInfo['nome']);
  final TextEditingController emailController = TextEditingController(text: userInfo['email']);
  final TextEditingController setorController = TextEditingController(text: userInfo['setor']);
  final TextEditingController senhaController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Editar Funcionário'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: emailController,
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
                controller: setorController,
                decoration: const InputDecoration(labelText: 'Setor'),
              ),
              TextFormField(
                controller: senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (String? senha) {
                  if (senha == null || senha.isEmpty) {
                    return 'Digite uma senha';
                  }
                  if (senha.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Atualizar as informações do funcionário
                SharedPreferences prefs = await SharedPreferences.getInstance();
                userInfo['nome'] = nomeController.text;
                userInfo['email'] = emailController.text;
                userInfo['setor'] = setorController.text;
                if (senhaController.text.isNotEmpty) {
                  userInfo['senha'] = senhaController.text;
                }
                await prefs.setString('usuarioLogado', jsonEncode(userInfo));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fenomenos SM'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),
      drawer: const DrawerFenomenos(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final userInfo = await _informacoesUsuarioLogado();
          if (userInfo != null) {
            _editarFuncionario(context, userInfo);

          }
        },
        child: const Icon(Icons.edit),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _informacoesUsuarioLogado(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Erro ao carregar informações do usuário'),
            );
          }

          final userInfo = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Text(userInfo['nome']),
                    subtitle: Text(userInfo['email']),
                    leading: Text('${userInfo['idFuncionario']}'),
                    trailing: Text(userInfo['setor']),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProdutosPage()));
                  },
                  child: const Text('Consulta de Produtos'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MovimentacoesEstoquePage()));
                  },
                  child: const Text('Movimentações do Estoque'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
