import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComprasDetalhesDataPage extends StatelessWidget {
  const ComprasDetalhesDataPage({
    super.key,
    required this.compra,
  });

  final Map<String, dynamic> compra;

  @override
  Widget build(BuildContext context) {
    final data = DateTime.parse(compra['data']);
    final dataFormatada = DateFormat('dd/MM/yyyy').format(data);
    final horarioFormatado = DateFormat('HH:mm').format(data);

    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'comprasDetalhesDataTitulo',
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(Icons.calendar_month_rounded, color: Colors.cyan),
              title: Text(
                'Data',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
      body: Hero(
        tag: 'listTileCompraDetalhesData',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              Icons.calendar_month_outlined,
              color: Colors.cyan.withValues(alpha: 0.5),
            ),
            title: Text(dataFormatada),
            subtitle: Text(horarioFormatado),
          ),
        ),
      ),
    );
  }
}
