import 'package:flutter/material.dart';
import 'package:front_mercado/widgets/drawer.dart';

class MovimentacoesEstoquePage extends StatefulWidget {
  const MovimentacoesEstoquePage({super.key});

  @override
  State<MovimentacoesEstoquePage> createState() =>
      _MovimentacoesEstoquePageState();
}

class _MovimentacoesEstoquePageState extends State<MovimentacoesEstoquePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentações Estoque'),
      ),
      drawer: const DrawerFenomenos(),
    );
  }
}
