import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/database_service.dart';
import '../widgets/common.dart';
import 'producto_form_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});
  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final _db = DatabaseService.instance;
  final _buscar = TextEditingController();
  String _filtro = '';
  late Future<List<Producto>> _futuro = _db.getProductos();

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _futuro = _db.getProductos(filtro: _filtro);
    });
  }

  Future<void> _abrirForm([Producto? p]) async {
    final ok = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => ProductoFormScreen(producto: p)));
    if (ok == true) {
      _recargar();
      if (mounted) {
        mostrarMensaje(context,
            p == null ? 'Producto registrado' : 'Producto actualizado');
      }
    }
  }

  Future<void> _eliminar(Producto p) async {
    if (!await confirmar(context,
        titulo: 'Eliminar producto',
        mensaje: '¿Deseas eliminar "${p.nombre}"?')) {
      return;
    }
    try {
      await _db.deleteProducto(p.id!);
      _recargar();
      if (mounted) mostrarMensaje(context, 'Producto eliminado');
    } catch (e) {
      if (mounted) {
        mostrarMensaje(context, 'No se pudo eliminar: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Productos')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _abrirForm(),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
        ),
        body: Centrado(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _buscar,
                decoration: InputDecoration(
                  hintText: 'Buscar producto por nombre',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _filtro.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _buscar.clear();
                            _filtro = '';
                            _recargar();
                          }),
                ),
                onChanged: (v) {
                  _filtro = v;
                  _recargar();
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Producto>>(
                future: _futuro,
                builder: (context, snap) {
                  if (snap.hasError) return ErrorState(snap.error!);
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final lista = snap.data!;
                  if (lista.isEmpty) {
                    return EmptyState(
                        icon: Icons.inventory_2_outlined,
                        titulo: _filtro.isEmpty
                            ? 'Aún no hay productos'
                            : 'Sin resultados',
                        mensaje: _filtro.isEmpty
                            ? 'Registra primero un proveedor y luego toca "Nuevo".'
                            : 'No hay productos que coincidan con "$_filtro".');
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                    itemCount: lista.length,
                    itemBuilder: (_, i) => _ProductoCard(
                        producto: lista[i],
                        onEdit: () => _abrirForm(lista[i]),
                        onDelete: () => _eliminar(lista[i])),
                  );
                },
              ),
            ),
          ]),
        ),
      );
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ProductoCard(
      {required this.producto, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bajo = producto.stock <= 5;
    final color = bajo ? Colors.red.shade700 : Colors.teal.shade700;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(producto.nombre,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.local_shipping,
                    size: 16, color: Colors.indigo),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(producto.proveedorNombre ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700))),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.attach_money, size: 16),
                    label: Text(producto.precio.toStringAsFixed(2))),
                Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: color.withValues(alpha: .1),
                    avatar: Icon(Icons.inventory, size: 16, color: color),
                    label: Text('Stock: ${producto.stock}',
                        style: TextStyle(color: color))),
              ]),
            ]),
          ),
          Column(children: [
            IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit),
            IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete),
          ]),
        ]),
      ),
    );
  }
}
