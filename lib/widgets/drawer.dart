import 'package:flutter/material.dart';

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
          // Compras
          onTap: () {
            print('Clicou no Compras');
          },
          onLongPress: () {
            print('Pressionou no Compras');
          },
          child: const ListTile(
            title: Text('Compras'),
            leading: Icon(Icons.shopping_cart),
          ),
        ),
        InkWell(
          // Estoque
          onTap: () {
            print('Clicou em Estoque');
          },
          onLongPress: () {
            print('Pressionou o Estoque');
          },
          child: const ListTile(
            title: Text('Estoque'),
            leading: Icon(Icons.inventory_2_outlined),
          ),
        ),
        InkWell(
          onTap: () {
            print('Clicou no Fornecedor');
          },
          onLongPress: () {
            print('Pressionou o Fornecedor');
          },
          child: const ListTile(
            title: Text('Fornecedor'),
            leading: Icon(Icons.fire_truck_outlined),
          ),
        ),
        InkWell(
          onTap: () {
            print('Funcionarios');
          },
          onLongPress: () {
            print('Pressionou no Funcionarios');
          },
          child: const ListTile(
            title: Text('Funcionarios'),
            leading: Icon(Icons.group),
          ),
        ),
        InkWell(
          onTap: () {
            print('Clicou no Movimentacoes Estoque');
          },
          onLongPress: () {
            print('Pressionou o MovimentacoesEstoque');
          },
          child: const ListTile(
            title: Text('Movimentações Estoque'),
            leading: Icon(Icons.forklift),
          ),
        ),
        InkWell(
          onTap: () {
            print('Clicou no Produtos');
          },
          onLongPress: () {
            print('Pressionou o Produtos');
          },
          child: const ListTile(
            title: Text('Produtos'),
            leading: Icon(Icons.sell_outlined),
          ),
        ),
        InkWell(
          onTap: () {
            print('Clicou no Tipos Estoque');
          },
          onLongPress: () {
            print('Tipos Estoque');
          },
          child: const ListTile(
            title: Text('Tipos Estoque'),
            leading: Icon(Icons.inventory_outlined),
          ),
        ),
        InkWell(
          onTap: () {
            print('Clicou no Tipos Movimentacao Estoque');
          },
          onLongPress: () {
            print('Pressionou no Tipos Movimentacao Estoque');
          },
          child: const ListTile(
            title: Text('Tipos Movimentacao Estoque'),
            leading: Icon(Icons.move_down),
          ),
        )
      ],
    );
  }
}