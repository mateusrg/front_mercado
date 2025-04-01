import 'package:flutter/material.dart';

class DialogVerificacaoFuncionarioAutenticador extends StatefulWidget {
  final Map<String, dynamic> funcionario;

  const DialogVerificacaoFuncionarioAutenticador(
      {super.key, required this.funcionario});

  @override
  State<DialogVerificacaoFuncionarioAutenticador> createState() =>
      _DialogVerificacaoFuncionarioAutenticadorState();
}

class _DialogVerificacaoFuncionarioAutenticadorState
    extends State<DialogVerificacaoFuncionarioAutenticador> {
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
              labelText: 'Senha do Autenticador',
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
