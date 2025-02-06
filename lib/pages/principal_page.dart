import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front_mercado/pages/fornecedores/fornecedores_page.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_page.dart';
import 'package:front_mercado/pages/login_page.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrincipalPage extends StatelessWidget {
  const PrincipalPage({super.key});

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
      drawer: const drawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('clicou no Editar');
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: Text(userInfo['nome']),
                subtitle: Text(userInfo['email']),
                leading: Text('${userInfo['idFuncionario']}'),
                trailing: Text(userInfo['setor']),
              ),
            ),
          );
        },
      ),
    );
  }
}
