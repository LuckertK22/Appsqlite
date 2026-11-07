import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../models/proveedor.dart';
import '../services/database_service.dart';
import '../widgets/common.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;
  const ProductoFormScreen({super.key, this.producto});
  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _form = GlobalKey<FormState>();
  final _db = DatabaseService.instance;
  late final _nombre = TextEditingController(text: widget.producto?.nombre);
  late final _precio =
      TextEditingController(text: widget.producto?.precio.toString());
  late final _stock =
      TextEditingController(text: widget.producto?.stock.toString());
  late final Future<List<Proveedor>> _proveedores = _db.getProveedores();
  int? _proveedorId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _proveedorId = widget.producto?.proveedorId;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    final p = Producto(
      id: widget.producto?.id,
      nombre: _nombre.text.trim(),
      precio: double.parse(_precio.text.trim().replaceAll(',', '.')),
      stock: int.parse(_stock.text.trim()),
      proveedorId: _proveedorId!,
    );
    try {
      p.id == null ? await _db.insertProducto(p) : await _db.updateProducto(p);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        mostrarMensaje(context, 'No se pudo guardar: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.producto != null;
    return Scaffold(
      appBar:
          AppBar(title: Text(editando ? 'Editar producto' : 'Nuevo producto')),
      body: Centrado(
        child: FutureBuilder<List<Proveedor>>(
          future: _proveedores,
          builder: (context, snap) {
            if (snap.hasError) return ErrorState(snap.error!);
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final provs = snap.data!;
            if (provs.isEmpty) {
              return const EmptyState(
                  icon: Icons.local_shipping_outlined,
                  titulo: 'Necesitas un proveedor',
                  mensaje:
                      'Registra al menos un proveedor antes de crear productos.');
            }
            return Form(
              key: _form,
              child: ListView(padding: const EdgeInsets.all(20), children: [
                TextFormField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Nombre del producto *',
                      prefixIcon: Icon(Icons.label)),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precio,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Precio unitario *',
                      prefixIcon: Icon(Icons.attach_money)),
                  validator: (v) {
                    final n =
                        double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                    if (n == null) return 'Ingresa un número válido';
                    if (n < 0) return 'No puede ser negativo';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Stock disponible *',
                      prefixIcon: Icon(Icons.inventory)),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null) return 'Ingresa un entero válido';
                    if (n < 0) return 'No puede ser negativo';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _proveedorId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Proveedor *',
                      prefixIcon: Icon(Icons.local_shipping)),
                  items: [
                    for (final p in provs)
                      DropdownMenuItem(value: p.id, child: Text(p.nombre)),
                  ],
                  onChanged: (v) => setState(() => _proveedorId = v),
                  validator: (v) =>
                      v == null ? 'Selecciona un proveedor' : null,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: const Icon(Icons.save),
                  label: Text(editando ? 'Guardar cambios' : 'Registrar'),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }
}
