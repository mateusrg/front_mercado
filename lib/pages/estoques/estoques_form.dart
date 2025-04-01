import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/estoques/modais/dialog_pesquisa_tipo_estoque.dart';
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
  Map<String, dynamic>? _tipoSelecionado;
  List<Map<String, dynamic>> _tiposEstoque = [];
  bool _carregando = false;
  bool _tiposCarregados = false;

  @override
  void initState() {
    super.initState();
    _carregarTiposEstoque();
  }

  Future<void> _carregarTiposEstoque() async {
    try {
      final response = await http.get(
        Uri.http(Params.apiUrl, '/TiposEstoque'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        final List<Map<String, dynamic>> tipos = decodedBody is List
            ? List<Map<String, dynamic>>.from(decodedBody)
            : [decodedBody as Map<String, dynamic>];

        setState(() {
          _tiposEstoque = tipos;
          _tiposCarregados = true;

          if (widget.estoque != null) {
            final idTipo = widget.estoque!['idTipoEstoque'];
            if (idTipo != null) {
              _tipoSelecionado = tipos.firstWhere(
                (tipo) => tipo['idTipoEstoque'] == idTipo,
                orElse: () => {},
              );
            }
            _descricaoController.text =
                widget.estoque!['descricaoEstoque'] ?? '';
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
      setState(() => _carregando = true);

      Map<String, dynamic> estoque = {
        'descricao': _descricaoController.text,
        'idTipoEstoque': _tipoSelecionado?['idTipoEstoque'],
      };
      if (widget.estoque?['idEstoque'] != null) {
        estoque = {
          'idEstoque': widget.estoque?['idEstoque'],
          'descricao': _descricaoController.text,
          'idTipoEstoque': _tipoSelecionado?['idTipoEstoque'],
        };
      }

      try {
        final response = widget.estoque == null
            ? await http.post(
                Uri.http(Params.apiUrl, '/Estoques'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(estoque),
              )
            : await http.put(
                Uri.http(Params.apiUrl, '/Estoques'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(estoque),
              );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (mounted) {
            Navigator.of(context).pop({
              'estoque': _descricaoController.text,
              'idTipoEstoque': _tipoSelecionado?['idTipoEstoque'],
              'tipoEstoque': _tipoSelecionado?['descricao'],
            });
          }
        } else {
          final erro = json.decode(response.body);
          _mostrarErro('Erro: ${erro['message'] ?? 'Erro desconhecido'}');
        }
      } catch (e) {
        _mostrarErro('Erro na conexão: ${e.toString()}');
      } finally {
        setState(() => _carregando = false);
      }
    }
  }

  void _mostrarErro(String mensagem) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {}
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
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Insira a descrição' : null,
                    ),
                    const SizedBox(height: 16),
                    _tiposCarregados
                        ? Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<
                                    Map<String, dynamic>>(
                                  value: _tipoSelecionado,
                                  decoration: const InputDecoration(
                                      labelText: 'Tipo de Estoque'),
                                  items: _tiposEstoque.map((tipo) {
                                    return DropdownMenuItem(
                                      value: tipo,
                                      child: Text(tipo['descricao'] ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _tipoSelecionado = value),
                                  validator: (value) => value == null
                                      ? 'Selecione um tipo'
                                      : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () async {
                                  final tipo =
                                      await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (context) =>
                                        const DialogPesquisaTipoEstoque(),
                                  );
                                  if (tipo != null) {
                                    final encontrado = _tiposEstoque.firstWhere(
                                      (t) =>
                                          t['idTipoEstoque'] ==
                                          tipo['idTipoEstoque'],
                                      orElse: () => {},
                                    );
                                    if (encontrado != {}) {
                                      setState(
                                          () => _tipoSelecionado = encontrado);
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _salvarOuAlterarEstoque,
                      child: Text(
                          widget.estoque == null ? 'Cadastrar' : 'Alterar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
