import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;

class EstoquesFormPage extends StatefulWidget {
  final Map<String, dynamic>? estoque;

  const EstoquesFormPage({this.estoque, super.key});

  @override
  State<EstoquesFormPage> createState() => _EstoquesFormPageState();
}

class _EstoquesFormPageState extends State<EstoquesFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  String? _tipoSelecionado;
  List<Map<String, dynamic>> _tiposEstoque = [];
  bool _carregando = false;
  bool _tiposCarregados = false;

  @override
  void initState() {
    super.initState();
    _carregarTiposEstoque();
    if (widget.estoque != null) {
      _preencherCamposParaEdicao();
    }
  }

  void _preencherCamposParaEdicao() {
    _descricaoController.text = widget.estoque!['descricaoEstoque'] ?? '';
    _tipoSelecionado = widget.estoque!['idTipoEstoque']?.toString();
  }

  Future<void> _carregarTiposEstoque() async {
    try {
      final response = await http.get(
        Uri.http('${Params.ipApi}:5277', '/TiposEstoque'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          final dynamic decodedBody = json.decode(response.body);
          _tiposEstoque = decodedBody is List
              ? List<Map<String, dynamic>>.from(decodedBody)
              : [decodedBody as Map<String, dynamic>];

          _tiposCarregados = true;
          if (widget.estoque != null) {
            _tipoSelecionado = widget.estoque!['idTipoEstoque']?.toString();
          }
        });
      } else {
        _mostrarErro(
            'Erro ao carregar tipos de estoque: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Não foi possível se conectar com a API.');
    }
  }

  Future<void> _salvarOuAlterarEstoque() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _carregando = true;
    });

    final estoque = {
      'descricao': _descricaoController.text,
      'idTipoEstoque': _tipoSelecionado != null ? int.tryParse(_tipoSelecionado!) : null,
    };

    // Debug print statements added here
    print('Making request to: ${Uri.http('${Params.ipApi}:5277', widget.estoque == null ? '/api/Estoques' : '/api/Estoques/${widget.estoque!['id']}')}');
    print('With body: ${jsonEncode(estoque)}');
    print('Headers: ${{'Content-Type': 'application/json'}}');

    try {
      final response = widget.estoque == null
          ? await http.post(
              Uri.http('${Params.ipApi}:5277', '/api/Estoques'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(estoque),
            )
          : await http.put(
              Uri.http('${Params.ipApi}:5277', '/api/Estoques/${widget.estoque!['id']}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(estoque),
            );

      // Print response details for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.of(context).pop(true);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Erro desconhecido';
        _mostrarErro('Erro ao salvar/alterar estoque: $errorMessage (${response.statusCode})');
      }
    } catch (e) {
      print('Error caught: $e');  // Added error print
      _mostrarErro('Não foi possível se conectar com a API: ${e.toString()}');
    } finally {
      setState(() {
        _carregando = false;
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
        title: Text(
            widget.estoque == null ? 'Cadastro de Estoque' : 'Alterar Estoque'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _tiposCarregados
                        ? DropdownButtonFormField<String>(
                            value: _tipoSelecionado,
                            decoration: const InputDecoration(
                                labelText: 'Tipo de Estoque'),
                            items: _tiposEstoque.map((tipo) {
                              final value =
                                  tipo['idTipoEstoque']?.toString() ?? '';
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(tipo['descricao'] ?? ''),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _tipoSelecionado = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, selecione um tipo de estoque';
                              }
                              return null;
                            },
                          )
                        : const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _salvarOuAlterarEstoque,
                      child:
                          Text(widget.estoque == null ? 'Salvar' : 'Alterar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
