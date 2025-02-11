import 'package:flutter/material.dart';
import 'package:front_mercado/widgets/drawer.dart';

class FuncionariosPage extends StatefulWidget {
  const FuncionariosPage({super.key});

  @override
  State<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends State<FuncionariosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Funcionarios'),
        ),
        drawer: const DrawerFenomenos());
  }
}
