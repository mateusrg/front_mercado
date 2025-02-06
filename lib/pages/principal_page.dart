import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front_mercado/pages/login_page.dart';
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
      drawer: NavigationDrawer(
        children: [
            Text('Fenomenos SM'),

          InkWell( // Compras
            onTap: () {
              print('Clicou no Compras');
            },
            onLongPress: () {
              print('Pressionou no Compras');
            },
            child: const ListTile(
              title: Text('Compras'),
              leading: Icon(Icons.shopping_cart),
            ),
          ),
          InkWell( // Estoque
            onTap: () {
              print('Clicou em Estoque');
            },
            onLongPress: () {
              print('Pressionou o Estoque');
            },
            child: const ListTile(
              title: Text('Estoque'),
              leading: Icon(Icons.inventory_2_outlined),
            ),
          ),
          InkWell(
            onTap: () {
              print('Clicou no Fornecedor');
            },
            onLongPress: () {
              print('Pressionou o Fornecedor');
            },            
            child: const ListTile(
              title: Text('Fornecedor'),
              leading: Icon(Icons.fire_truck_outlined),
            ),
          ),
          InkWell(
            onTap: () {
              print('Funcionarios');
            },
            onLongPress: () {
              print('Pressionou no Funcionarios');
            },
            child: const ListTile(
              title: Text('Funcionarios'),
              leading: Icon(Icons.group),
            ),
          ),
          InkWell(
            onTap: () {
              print('Clicou no Movimentacoes Estoque');
            },
            onLongPress: () {
              print('Pressionou o MovimentacoesEstoque');
            },
            child: const ListTile(
              title: Text('Movimentações Estoque'),
              leading: Icon(Icons.forklift),
            ),
          ),
          InkWell(
            onTap: () {
              print('Clicou no Produtos');
            },
            onLongPress: () {
              print('Pressionou o Produtos');
            },
            child: const ListTile(
              title: Text('Produtos'),
              leading: Icon(Icons.sell_outlined),
            ),
          ),
          InkWell(
            onTap: () {
              print('Clicou no Tipos Estoque');
            },
            onLongPress: () {
              print('Tipos Estoque');
            },
            child: const ListTile(
              title: Text('Tipos Estoque'),
              leading: Icon(Icons.inventory_outlined),
            ),
          ),
          InkWell(
            onTap: () {
              print('Clicou no Tipos Movimentacao Estoque');
            },
            onLongPress: () {
              print('Pressionou no Tipos Movimentacao Estoque');
            },
            child: const ListTile(
              title: Text('Tipos Movimentacao Estoque'),
              leading: Icon(Icons.move_down),
            ),
          )

        ],
      ),

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
          return  Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('ID: ${userInfo['idFuncionario']}'),
                Text('Nome: ${userInfo['nome']}'),
                Text('Email: ${userInfo['email']}'),
                Text('Setor: ${userInfo['setor']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
