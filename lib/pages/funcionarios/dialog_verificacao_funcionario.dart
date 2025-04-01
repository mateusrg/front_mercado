import 'package:flutter/material.dart';

class DialogVerificacaoFuncionario extends StatefulWidget {
  final Map<String, dynamic> funcionario;

  const DialogVerificacaoFuncionario({super.key, required this.funcionario});

  @override
  State<DialogVerificacaoFuncionario> createState() =>
      _DialogVerificacaoFuncionarioState();
}

class _DialogVerificacaoFuncionarioState
    extends State<DialogVerificacaoFuncionario> {
  final _senhaController = TextEditingController();
  bool _senhaIncorreta = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verificação de Segurança'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: ListTile(
              title: Text(widget.funcionario['nome']),
              subtitle: Text(widget.funcionario['email']),
              trailing: Text(widget.funcionario['setor']),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _senhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha Atual do Funcionário',
              errorText: _senhaIncorreta ? 'Senha incorreta' : null,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final senhaDigitada = _senhaController.text;
            final senhaCorreta = senhaDigitada == widget.funcionario['senha'];

            if (senhaCorreta) {
              Navigator.pop(context, true);
            } else {
              setState(() => _senhaIncorreta = true);
            }
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
