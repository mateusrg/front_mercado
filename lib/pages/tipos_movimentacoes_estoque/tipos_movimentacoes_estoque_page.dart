import 'package:flutter/material.dart';
import 'package:front_mercado/widgets/drawer.dart';

class TiposMovimentacoesEstoquePage extends StatefulWidget {
  const TiposMovimentacoesEstoquePage({super.key});

  @override
  State<TiposMovimentacoesEstoquePage> createState() => _TiposMovimentacoesEstoquePageState();
}

class _TiposMovimentacoesEstoquePageState extends State<TiposMovimentacoesEstoquePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tipos Movimentações Estoque'),),
      drawer: drawer(),
    );
  }
}