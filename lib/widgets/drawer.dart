import 'package:flutter/material.dart';
import 'package:front_mercado/pages/compras/compras_page.dart';
import 'package:front_mercado/pages/estoque/estoque_page.dart';
import 'package:front_mercado/pages/fornecedores/fornecedores_page.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_page.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_page.dart';
import 'package:front_mercado/pages/principal_page.dart';
import 'package:front_mercado/pages/produtos/produtos_page.dart';
import 'package:front_mercado/pages/tipos_estoque/tipos_estoque_page.dart';
import 'package:front_mercado/pages/tipos_movimentacoes_estoque/tipos_movimentacoes_estoque_page.dart';

class DrawerFenomenos extends StatelessWidget {
  const DrawerFenomenos({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    width: 70,
                    height: 70,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Fenômenos SM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            text: 'Home',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrincipalPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart,
            text: 'Compras',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComprasPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.inventory_2_outlined,
            text: 'Estoque',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EstoquePage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.fire_truck_outlined,
            text: 'Fornecedor',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FornecedoresPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.group,
            text: 'Funcionarios',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FuncionariosPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.forklift,
            text: 'Movimentações Estoque',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MovimentacoesEstoquePage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.sell_outlined,
            text: 'Produtos',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProdutosPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.inventory_outlined,
            text: 'Tipos Estoque',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TiposEstoquePage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.move_down,
            text: 'Tipos Movimentações Estoque',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TiposMovimentacoesEstoquePage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      title: Text(text),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}
