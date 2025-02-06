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

class drawer extends StatelessWidget {
  const drawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        Text('Fenomenos SM'),

          InkWell( 
            onTap: () { 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrincipalPage())
              );
            },
            child: const ListTile(
              title: Text('Home'),
              leading: Icon(Icons.home),
            ),
          ),

          InkWell( 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComprasPage())
              );
            },
            child: const ListTile(
              title: Text('Compras'),
              leading: Icon(Icons.shopping_cart),
            ),
          ),

          InkWell( 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EstoquePage())
              );
            },
            child: const ListTile(
              title: Text('Estoque'),
              leading: Icon(Icons.inventory_2_outlined),
            ),
          ),

          InkWell( 
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FornecedoresPage()),
                );
            },       
            child: const ListTile(
              title: Text('Fornecedor'),
              leading: Icon(Icons.fire_truck_outlined),
            ),
          ),

          InkWell( 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FuncionariosPage()),
              );
            },
            child: const ListTile(
              title: Text('Funcionarios'),
              leading: Icon(Icons.group),
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MovimentacoesEstoquePage())
                );
            },
            child: const ListTile(
              title: Text('Movimentações Estoque'),
              leading: Icon(Icons.forklift),
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProdutosPage())
                );
            },
            child: const ListTile(
              title: Text('Produtos'),
              leading: Icon(Icons.sell_outlined),
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TiposEstoquePage())
              );
            },
            child: const ListTile(
              title: Text('Tipos Estoque'),
              leading: Icon(Icons.inventory_outlined),
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TiposMovimentacoesEstoquePage())
              );
            },
            child: const ListTile(
              title: Text('Tipos Movimentações Estoque'),
              leading: Icon(Icons.move_down),
            ),
          ),
      ],
    );
  }
}