import 'package:flutter/material.dart';
import 'package:front_mercado/widgets/drawer.dart';

class TiposEstoquePage extends StatefulWidget {
  const TiposEstoquePage({super.key});

  @override
  State<TiposEstoquePage> createState() => _TiposEstoquePageState();
}

class _TiposEstoquePageState extends State<TiposEstoquePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tipos Estoque'),),
      drawer: drawer(),
    );
  }
}