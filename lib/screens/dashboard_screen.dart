import 'package:flutter/material.dart';

import '../routes.dart';
import '../services/database_service.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<int>> _totales = _cargar();

  Future<List<int>> _cargar() async {
    final db = DatabaseService.instance;
    return [await db.totalProductos(), await db.totalProveedores()];
  }

  Future<void> _ir(String ruta) async {
    await Navigator.pushNamed(context, ruta);
    if (mounted) {
      setState(() {
        _totales = _cargar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      body: Centrado(
        child: FutureBuilder<List<int>>(
          future: _totales,
          builder: (context, snap) {
            final t = snap.data;
            return ListView(padding: EdgeInsets.zero, children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                    24, MediaQuery.of(context).padding.top + 32, 24, 32),
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.inventory_2, color: Colors.white, size: 40),
                      SizedBox(height: 12),
                      Text('StockFácil',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      Text('Controla tu inventario y tus proveedores',
                          style: TextStyle(color: Colors.white70)),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _Resumen(
                                icon: Icons.category,
                                label: 'Productos',
                                valor: t?[0],
                                color: Colors.orange.shade700)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _Resumen(
                                icon: Icons.local_shipping,
                                label: 'Proveedores',
                                valor: t?[1],
                                color: Colors.indigo)),
                      ]),
                      const SizedBox(height: 24),
                      Text('Secciones',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      _Acceso(
                          icon: Icons.category,
                          titulo: 'Productos',
                          sub: 'Consulta, registra y edita tu catálogo',
                          color: Colors.orange.shade700,
                          onTap: () => _ir(Routes.productos)),
                      _Acceso(
                          icon: Icons.local_shipping,
                          titulo: 'Proveedores',
                          sub: 'Administra tus contactos de suministro',
                          color: Colors.indigo,
                          onTap: () => _ir(Routes.proveedores)),
                    ]),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? valor;
  final Color color;
  const _Resumen(
      {required this.icon,
      required this.label,
      required this.valor,
      required this.color});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: .12),
                child: Icon(icon, color: color)),
            const SizedBox(height: 12),
            Text(valor?.toString() ?? '–',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ]),
        ),
      );
}

class _Acceso extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _Acceso(
      {required this.icon,
      required this.titulo,
      required this.sub,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color)),
          title:
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(sub),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
