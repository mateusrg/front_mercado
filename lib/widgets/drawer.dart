import 'package:flutter/material.dart';
import 'package:front_mercado/pages/compras/compras_page.dart';
import 'package:front_mercado/pages/estoques/estoque_page.dart';
import 'package:front_mercado/pages/fornecedores/fornecedores_page.dart';
import 'package:front_mercado/pages/funcionarios/funcionarios_page.dart';
import 'package:front_mercado/pages/movimentacoes_estoque/movimentacoes_estoque_page.dart';
import 'package:front_mercado/pages/principal_page.dart';
import 'package:front_mercado/pages/produtos/produtos_page.dart';
import 'package:front_mercado/pages/tipos_estoque/tipos_estoque_page.dart';
import 'package:front_mercado/pages/tipos_movimentacao_estoque/tipos_movimentacao_estoque_page.dart';

class DrawerFenomenos extends StatelessWidget {
  const DrawerFenomenos(this.pagina, {super.key});

  final String pagina;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fenomenossm.jpg'),
                fit: BoxFit.cover,
              ),
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
            isSelected: pagina == 'Home',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PrincipalPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart,
            text: 'Compras',
            isSelected: pagina == 'Compras',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ComprasPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.warehouse_rounded,
            text: 'Estoques',
            isSelected: pagina == 'Estoques',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EstoquePage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.fire_truck,
            text: 'Fornecedores',
            isSelected: pagina == 'Fornecedores',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FornecedoresPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.group,
            text: 'Funcionários',
            isSelected: pagina == 'Funcionarios',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FuncionariosPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.forklift,
            text: 'Movimentações de Estoque',
            isSelected: pagina == 'Movimentações de Estoque',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MovimentacoesEstoquePage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shopping_bag,
            text: 'Produtos',
            isSelected: pagina == 'Produtos',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProdutosPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.inventory_rounded,
            text: 'Tipos de Estoque',
            isSelected: pagina == 'Tipos de Estoque',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TiposEstoquePage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.move_down_rounded,
            text: 'Tipos de Movimentação de Estoque',
            isSelected: pagina == 'Tipos de Movimentação de Estoque',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const TiposMovimentacoesEstoquePage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool isSelected,
    required GestureTapCallback onTap,
  }) {
    Color corItemSelecionado = Colors.cyan;
    switch (pagina) {
      case 'Compras':
        corItemSelecionado = Colors.yellow;
        break;
      case 'Estoques':
        corItemSelecionado = Colors.blue;
        break;
      case 'Fornecedores':
        corItemSelecionado = Colors.green;
        break;
      case 'Funcionarios':
        corItemSelecionado = Colors.yellow;
        break;
      case 'Movimentações de Estoque':
        corItemSelecionado = Colors.blue;
        break;
      case 'Produtos':
        corItemSelecionado = Colors.green;
        break;
      case 'Tipos de Estoque':
        corItemSelecionado = Colors.yellow;
        break;
      case 'Tipos de Movimentação de Estoque':
        corItemSelecionado = Colors.blue;
        break;
      default:
        corItemSelecionado = Colors.cyan;
    }

    return ListTile(
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? corItemSelecionado : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      leading: Icon(
        icon,
        color: isSelected ? corItemSelecionado : null,
      ),
      onTap: isSelected ? null : onTap,
    );
  }
}
