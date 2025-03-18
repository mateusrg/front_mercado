import 'package:flutter/material.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacao_estoque_dialog_produtos.dart';
import 'package:front_mercado/params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class TransferenciaEstoquePage extends StatefulWidget {
  const TransferenciaEstoquePage({super.key});

  @override
  State<TransferenciaEstoquePage> createState() =>
      _TransferenciaEstoquePageState();
}

class _TransferenciaEstoquePageState extends State<TransferenciaEstoquePage> {
  final _formKey = GlobalKey<FormState>();
  final urlApi = '${Params.ipApi}:5277';
  late TextEditingController _quantidadeController;
  late TextEditingController _horaController;
  bool _salvando = false;
  bool _carregando = true;
  List<Map<String, dynamic>> _produtos = [];
  List<Map<String, dynamic>> _estoques = [];
  List<Map<String, dynamic>> _funcionarios = [];
  Map<String, dynamic>? _produtoSelecionado;
  Map<String, dynamic>? _estoqueOrigemSelecionado;
  Map<String, dynamic>? _estoqueDestinoSelecionado;
  Map<String, dynamic>? _funcionarioSolicitadorSelecionado;
  Map<String, dynamic>? _funcionarioAutenticadorSelecionado;
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    _quantidadeController = TextEditingController();
    _horaController =
        TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));
    _dataSelecionada = DateTime.now();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _carregarProdutos();
    await _carregarEstoques();
    await _carregarFuncionarios();
    setState(() {
      _carregando = false;
    });
  }

  Future<void> _carregarProdutos() async {
    final response = await http.get(Uri.http(urlApi, '/Produtos'));
    if (response.statusCode == 200) {
      setState(() {
        _produtos = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      _mostrarErro('Erro ao carregar produtos: ${response.statusCode}');
    }
  }

  Future<void> _carregarEstoques() async {
    final response = await http.get(Uri.http(urlApi, '/Estoques'));
    if (response.statusCode == 200) {
      setState(() {
        _estoques = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      _mostrarErro('Erro ao carregar estoques: ${response.statusCode}');
    }
  }

  Future<void> _carregarFuncionarios() async {
    final response = await http.get(Uri.http(urlApi, '/Funcionarios'));
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final usuarioLogadoString = prefs.getString('usuarioLogado');
      if (usuarioLogadoString != null) {
        final usuarioLogado = json.decode(usuarioLogadoString);

        setState(() {
          _funcionarios =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _funcionarioSolicitadorSelecionado = _funcionarios.firstWhere(
              (funcionario) =>
                  funcionario['idFuncionario'] ==
                  usuarioLogado['idFuncionario']);
        });
      }
    } else {
      _mostrarErro('Erro ao carregar funcionários: ${response.statusCode}');
    }
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _salvando = true;
      });

      final movimentacao = {
        'idProduto': _produtoSelecionado!['idProduto'],
        'quantidade': int.parse(_quantidadeController.text),
        'idEstoqueOrigem': _estoqueOrigemSelecionado!['idEstoque'],
        'idEstoqueDestino': _estoqueDestinoSelecionado!['idEstoque'],
        'idFuncionarioSolicitador':
            _funcionarioSolicitadorSelecionado!['idFuncionario'],
        'idFuncionarioAutenticador':
            _funcionarioAutenticadorSelecionado!['idFuncionario'],
        'idTipoMovimentacaoOrigem': 6,
        'idTipoMovimentacaoDestino': 7,
        'dataHora':
            '${DateFormat('yyyy-MM-dd').format(_dataSelecionada!)}T${_horaController.text}:00.000Z',
      };

      try {
        final response = await http.post(
          Uri.http(
              urlApi, 'MovimentacoesEstoque/movimentarProdutoEntreEstoques'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(movimentacao),
        );

        if (response.statusCode == 200) {
          Navigator.of(context).pop();
        } else if (response.statusCode == 400) {
          _mostrarErro('Quantidade insuficiente em estoque.');
        } else {
          _mostrarErro(
              'Erro ao realizar transferência: ${response.statusCode}');
        }
      } catch (e) {
        _mostrarErro('Não foi possível se conectar com a API.');
      } finally {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? selecionado = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (selecionado != null && selecionado != _dataSelecionada) {
      setState(() {
        _dataSelecionada = selecionado;
      });
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

  void _abrirDialogPesquisaProduto() async {
    Map<String, dynamic>? produtoSelecionado = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogPesquisaProduto();
      },
    );
    if (produtoSelecionado != null) {
      for (var produto in _produtos) {
        if (produto['idProduto'] == produtoSelecionado['idProduto']) {
          setState(() {
            _produtoSelecionado = produto;
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transferência de Estoque'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferência de Estoque'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: _produtoSelecionado,
                        decoration: const InputDecoration(labelText: 'Produto'),
                        items: _produtos.map((produto) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: produto,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8 -
                                        32,
                              ),
                              child: Text(
                                '${produto['descricao']} - ${produto['codBarras']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          print(value);
                          setState(() {
                            _produtoSelecionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione um produto';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _abrirDialogPesquisaProduto,
                    ),
                  ],
                ),
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
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _estoqueOrigemSelecionado,
                  decoration:
                      const InputDecoration(labelText: 'Estoque de Origem'),
                  items: _estoques.map((estoque) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: estoque,
                      child: Text(estoque['descricao']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _estoqueOrigemSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione um estoque de origem';
                    }
                    if (value == _estoqueDestinoSelecionado) {
                      return 'O estoque de origem e o de destino devem ser diferentes';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _estoqueDestinoSelecionado,
                  decoration:
                      const InputDecoration(labelText: 'Estoque de Destino'),
                  items: _estoques.map((estoque) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: estoque,
                      child: Text(estoque['descricao']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _estoqueDestinoSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione um estoque de destino';
                    }

                    if (value == _estoqueOrigemSelecionado) {
                      return 'O estoque de origem e o de destino devem ser diferentes';
                    }

                    return null;
                  },
                ),
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _funcionarioSolicitadorSelecionado,
                  decoration: const InputDecoration(
                      labelText: 'Funcionário Solicitador'),
                  items: _funcionarios.map((funcionario) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: funcionario,
                      child: Text(funcionario['nome']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _funcionarioSolicitadorSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione um funcionário solicitador';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _funcionarioAutenticadorSelecionado,
                  decoration: const InputDecoration(
                      labelText: 'Funcionário Autenticador'),
                  items: _funcionarios.map((funcionario) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: funcionario,
                      child: Text(funcionario['nome']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _funcionarioAutenticadorSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione um funcionário autenticador';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_dataSelecionada != null
                            ? DateFormat('dd/MM/yyyy').format(_dataSelecionada!)
                            : 'Selecione a data'),
                        onPressed: () => _selecionarData(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _horaController,
                        decoration: const InputDecoration(labelText: 'Hora'),
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          TextInputFormatter.withFunction((va, vn) {
                            final valorAntigo = va.text;
                            final valorNovo = vn.text;
                            final quantidade = valorNovo.length;

                            if (quantidade == 1) {
                              if (int.parse(valorNovo) <= 2) {
                                return vn;
                              }
                              return const TextEditingValue(text: '');
                            }

                            if (quantidade == 2) {
                              if (valorAntigo == '$valorNovo:') {
                                return TextEditingValue(text: valorNovo[0]);
                              }

                              if (valorNovo[0] == '2') {
                                if (int.parse(valorNovo[1]) < 4) {
                                  return TextEditingValue(text: '$valorNovo:');
                                }
                                return va;
                              }
                              return TextEditingValue(text: '$valorNovo:');
                            }

                            if (quantidade == 3) {
                              if (int.parse(valorNovo[2]) > 5) {
                                return va;
                              }
                              return TextEditingValue(
                                  text:
                                      '${valorNovo.substring(0, 2)}:${valorNovo[2]}');
                            }

                            if (quantidade == 4) {
                              return TextEditingValue(
                                  text:
                                      '${valorNovo.substring(0, 2)}:${valorNovo.substring(2)}');
                            }
                            return vn;
                          }),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira a hora';
                          }
                          if (value.length != 5) {
                            return 'Insira um horário válido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                      : const Text('Transferir'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
