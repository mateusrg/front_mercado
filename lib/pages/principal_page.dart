import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:front_mercado/pages/compras/compras_form.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_detalhes_page.dart';
import 'package:front_mercado/pages/login_page.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_page.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_vendas.dart';
import 'package:front_mercado/pages/produtos/produtos_page.dart';
import 'package:front_mercado/widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: const DrawerFenomenos('Home'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final funcionario = await _informacoesUsuarioLogado();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  FuncionariosDetalhesPage(funcionario: funcionario!),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.person_rounded),
      ),
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
                      text: 'Produtos',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProdutosPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      text: 'Movimentações',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MovimentacoesEstoquePage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      text: 'Comprar',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CompraFormPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      text: 'Vender',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VendaPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      'Fenômenos SM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        shadows: [
                          const Shadow(
                            blurRadius: 5.0,
                            color: Color.fromARGB(255, 151, 147, 147),
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
                          const Shadow(
                            blurRadius: 5.0,
                            color: Color.fromARGB(255, 92, 91, 91),
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

  Widget _buildUserInfoCard(Map<String, dynamic> userInfo) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person_rounded),
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
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0))),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
