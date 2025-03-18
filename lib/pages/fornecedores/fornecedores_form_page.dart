
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class FornecedorFormPage extends StatefulWidget {
  final Map<String, dynamic>? fornecedor;

  const FornecedorFormPage({super.key, this.fornecedor});

  @override
  State<FornecedorFormPage> createState() => _FornecedorFormPageState();
}

class _FornecedorFormPageState extends State<FornecedorFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late MaskedTextController _cnpjController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.fornecedor != null ? widget.fornecedor!['nome'] : '',
    );
    _cnpjController = MaskedTextController(
      mask: '00.000.000/0000-00',
      text: widget.fornecedor != null ? widget.fornecedor!['cnpj'] : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _salvando = true;
      });

      final fornecedor = {
        'nome': _nomeController.text,
        'cnpj': _cnpjController.text,
      };

      if (widget.fornecedor != null) {
        fornecedor['idFornecedor'] =
            widget.fornecedor!['idFornecedor'].toString();
      }

      try {
        Navigator.of(context).pop(fornecedor);
      } catch (e) {
        _mostrarErro('Não foi possível se conectar com a API.');
      } finally {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _salvar(), // Adicionado para executar ao pressionar Enter
              ),
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(labelText: 'CNPJ'),
                maxLength: 18,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CNPJ';
                  }
                  if (value.length != 18) {
                    return 'O CNPJ deve ter 18 caracteres';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _salvar(), // Adicionado para executar ao pressionar Enter
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text(widget.fornecedor == null ? 'Cadastrar' : 'Alterar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
