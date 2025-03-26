import 'package:flutter/material.dart';

class FuncionariosDetalhesCardPage extends StatelessWidget {
  const FuncionariosDetalhesCardPage({
    super.key,
    required this.funcionario,
  });

  final Map<String, dynamic> funcionario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'tituloFuncionariosDetalhesCard',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.cyan,
              ),
              title: Text(
                'Funcionário',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: Hero(
        tag: 'listTileFuncionariosDetalhesCard',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              Icons.person_outline,
              color: Colors.cyan.withAlpha(128),
            ),
            title: Text(funcionario['nome']),
            subtitle: Text(funcionario['email']),
            trailing: Text(funcionario['setor']),
          ),
        ),
      ),
    );
  }
}
