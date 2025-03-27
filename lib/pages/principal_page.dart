import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/compras/compras_form.dart';
import 'package:front_mercado/pages/login_page.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_page.dart';
import 'package:front_mercado/pages/produtos/produtos_page.dart';
import 'package:front_mercado/params.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const String apiUrl = Params.apiUrl;

  Future<void> _deslogar(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioLogado');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Você realmente deseja sair?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deslogar(context);
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _informacoesUsuarioLogado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonInformacoesUsuarioLogado = prefs.getString('usuarioLogado');
    if (jsonInformacoesUsuarioLogado != null) {
      return convert.jsonDecode(jsonInformacoesUsuarioLogado);
    }
    return null;
  }

  void _editarFuncionario(BuildContext context, Map<String, dynamic> userInfo) {
  final TextEditingController nomeController =
      TextEditingController(text: userInfo['nome']);
  final TextEditingController emailController =
      TextEditingController(text: userInfo['email']);
  final TextEditingController setorController =
      TextEditingController(text: userInfo['setor']);
  final TextEditingController senhaAtualController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Editar Funcionário'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  maxLength: 100,
                  validator: (String? email) {
                    final RegExp emailRegex = RegExp(
                        r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

                    if (email == null || email.isEmpty) {
                      return 'Digite um e-mail';
                    }

                    if (!emailRegex.hasMatch(email)) {
                      return 'Digite um e-mail válido';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: setorController,
                  decoration: const InputDecoration(labelText: 'Setor'),
                ),
                TextFormField(
                  controller: senhaAtualController,
                  decoration: const InputDecoration(labelText: 'Senha Atual'),
                  obscureText: true,
                  validator: (String? senha) {
                    if (senha == null || senha.isEmpty) {
                      return 'Digite a senha atual';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: novaSenhaController,
                  decoration: const InputDecoration(labelText: 'Nova Senha'),
                  obscureText: true,
                  validator: (String? senha) {
                    if (senha != null && senha.isNotEmpty && senha.length < 6) {
                      return 'A nova senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (senhaAtualController.text == userInfo['senha']) {
                  _salvarEdicaoFuncionario(
                    context,
                    userInfo,
                    nomeController,
                    emailController,
                    setorController,
                    novaSenhaController,
                  );
                } else {
                  _mostrarErro('Senha atual incorreta.');
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
}

Future<void> _validarSenhaAtual(
  BuildContext context,
  Map<String, dynamic> userInfo,
  String senhaAtual,
  TextEditingController nomeController,
  TextEditingController emailController,
  TextEditingController setorController,
  TextEditingController novaSenhaController,
) async {
  try {
    final response = await http.post(
      Uri.http(apiUrl, '/Funcionarios/validarSenha'),
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode({
        'idFuncionario': userInfo['idFuncionario'],
        'senha': senhaAtual,
      }),
    );

    if (response.statusCode == 200) {
      // Senha válida, prosseguir com a edição
      _salvarEdicaoFuncionario(
        context,
        userInfo,
        nomeController,
        emailController,
        setorController,
        novaSenhaController,
      );
    } else {
      _mostrarErro('Senha atual incorreta.');
    }
  } catch (e) {
    _mostrarErro('Não foi possível validar a senha.');
  }
}

  Future<void> _salvarEdicaoFuncionario(
      BuildContext context,
      Map<String, dynamic> userInfo,
      TextEditingController nomeController,
      TextEditingController emailController,
      TextEditingController setorController,
      TextEditingController senhaController) async {
    if (_formKey.currentState!.validate()) {
      // Atualizar os dados editados
      userInfo['nome'] = nomeController.text;
      userInfo['email'] = emailController.text;
      userInfo['setor'] = setorController.text;

      // Só adiciona a senha se o campo não estiver vazio
      if (senhaController.text.isNotEmpty) {
        userInfo['senha'] = senhaController.text;
      }

      try {
        final response = await http.put(
          Uri.http(apiUrl, '/Funcionarios'),
          headers: {'Content-Type': 'application/json'},
          body: convert.jsonEncode(userInfo),
        );

        if (response.statusCode < 400) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('usuarioLogado', convert.jsonEncode(userInfo));

          // Fechar o diálogo
          Navigator.of(context).pop();

          // Atualizar a interface
          setState(() {});

          print(
              'Informações do usuário atualizadas: $userInfo'); // Log para depuração
        } else {
          _mostrarErro('Erro ao atualizar funcionário: ${response.statusCode}');
        }
      } catch (e) {
        _mostrarErro('Não foi possível se conectar com a API.');
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
      appBar: _buildAppBar(context),
      drawer: const DrawerFenomenos('Home'),
      floatingActionButton: _buildFloatingActionButton(context),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _informacoesUsuarioLogado(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Erro ao carregar informações do usuário'),
            );
          }

          final userInfo = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              _buildUserInfoCard(userInfo),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      text: 'Consulta de Produtos',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProdutosPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      text: 'Movimentações do Estoque',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MovimentacoesEstoquePage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2), // Espaçamento entre os botões
              _buildActionButton(
                context,
                text: 'Nova Compra',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CompraFormPage()),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.asset(
                    'assets/images/cartaofenomenos.png',
                    width: MediaQuery.of(context).size.width * 0.9,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      'Fenômenos SM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: const Color.fromARGB(255, 151, 147, 147),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'A Rede 5 estrelas em atendimento onde qualidade e economia brilham muito!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: const Color.fromARGB(255, 92, 91, 91),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Fenômenos SM'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _confirmarLogout(context),
        ),
      ],
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final userInfo = await _informacoesUsuarioLogado();
        if (userInfo != null) {
          _editarFuncionario(context, userInfo);
        }
      },
      child: const Icon(Icons.edit),
    );
  }

  Widget _buildUserInfoCard(Map<String, dynamic> userInfo) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20.0,
          backgroundImage: const AssetImage('assets/images/logo.png'),
        ),
        title: Text('${userInfo['idFuncionario']} - ${userInfo['nome']}'),
        subtitle: Text(userInfo['email']),
        trailing: Text(userInfo['setor']),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
