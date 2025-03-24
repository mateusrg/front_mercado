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

  @override
  void initState() {
    super.initState();
    _carregarTiposEstoque();
    if (widget.estoque != null) {
       _preencherCamposParaEdicao();
   }
  }

  void _preencherCamposParaEdicao() {
    widget.estoque!['descricaoEstoque'];
    widget.estoque!['descricaoTipoEstoque'];
    '${widget.estoque}\n${widget.estoque!['idTipoEstoque'].toString()}';
    _descricaoController.text = widget.estoque!['descricaoEstoque'];
    _tipoSelecionado = widget.estoque!['idTipoEstoque'].toString();
  }

  Future<void> _carregarTiposEstoque() async {
    try {
      final response = await http.get(
        Uri.http('${Params.ipApi}:5277', '/TiposEstoque'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _tiposEstoque = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _mostrarErro('Erro ao carregar tipos de estoque: ${response.statusCode}');
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
        'idTipoEstoque': _tipoSelecionado,
      };

      try {
        final response = widget.estoque == null
            ? await http.post(
                Uri.http('${Params.ipApi}:5277', '/Estoques'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(estoque),
              )
            : await http.put(
                Uri.http('${Params.ipApi}:5277', '/Estoques/${widget.estoque!['id']}'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(estoque),
              );

        if (response.statusCode < 400) {
          Navigator.of(context).pop(true); // Retorna sucesso
        } else {
          _mostrarErro('Erro ao salvar/alterar estoque: ${response.statusCode}');
        }
      } catch (e) {
        _mostrarErro('Não foi possível se conectar com a API.');
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
        title: Text(widget.estoque == null ? 'Cadastro de Estoque' : 'Alterar Estoque'),
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
                    DropdownButtonFormField<String>(
                      value: _tipoSelecionado,
                      decoration: const InputDecoration(labelText: 'Tipo de Estoque'),
                      items: _tiposEstoque.map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo['idTipoEstoque'].toString(),
                          child: Text(tipo['descricao']),
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
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _salvarOuAlterarEstoque,
                      child: Text(widget.estoque == null ? 'Salvar' : 'Alterar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}