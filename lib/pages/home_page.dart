import 'package:flutter/material.dart';
import 'package:front_mercado/pages/login_page.dart';
import 'package:front_mercado/pages/principal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String?> _paginaBaseadaNoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('usuarioLogado'));
    return prefs.getString('usuarioLogado');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _paginaBaseadaNoLogin(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao verificar login'));
        }

        if (snapshot.data == null) {
          return const LoginPage();
        }

        return const PrincipalPage();
      },
    );
  }
}
