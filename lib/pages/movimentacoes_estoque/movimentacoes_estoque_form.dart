import 'package:flutter/material.dart';

class MovimentacaoEstoqueFormPage extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onSave;

  const MovimentacaoEstoqueFormPage({super.key, required this.onSave});

  @override
  State<MovimentacaoEstoqueFormPage> createState() => _MovimentacaoEstoqueFormPageState();
}

class _MovimentacaoEstoqueFormPageState extends State<MovimentacaoEstoqueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _produtoController = TextEditingController();
  final TextEditingController _estoqueOrigemController = TextEditingController();
  final TextEditingController _estoqueDestinoController = TextEditingController();
  final TextEditingController _funcionarioSolicitadorController = TextEditingController();
  final TextEditingController _funcionarioAutenticadorController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _produtoController.dispose();
    _estoqueOrigemController.dispose();
    _estoqueDestinoController.dispose();
    _funcionarioSolicitadorController.dispose();
    _funcionarioAutenticadorController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _salvando = true;
      });

      await widget.onSave({
        'produto': _produtoController.text,
        'estoqueOrigem': _estoqueOrigemController.text,
        'estoqueDestino': _estoqueDestinoController.text,
        'funcionarioSolicitador': _funcionarioSolicitadorController.text,
        'funcionarioAutenticador': _funcionarioAutenticadorController.text,
        'quantidade': int.parse(_quantidadeController.text),
      });

      setState(() {
        _salvando = false;
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Movimentação de Estoque'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _produtoController,
                decoration: const InputDecoration(labelText: 'Produto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _estoqueOrigemController,
                decoration: const InputDecoration(labelText: 'Estoque de Origem'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o estoque de origem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _estoqueDestinoController,
                decoration: const InputDecoration(labelText: 'Estoque de Destino'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o estoque de destino';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _funcionarioSolicitadorController,
                decoration: const InputDecoration(labelText: 'Funcionário Solicitador'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o funcionário solicitador';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _funcionarioAutenticadorController,
                decoration: const InputDecoration(labelText: 'Funcionário Autenticador'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o funcionário autenticador';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _salvando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _salvar,
                      child: const Text('Salvar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}