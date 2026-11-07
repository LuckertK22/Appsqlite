import 'package:flutter/material.dart';

import '../models/proveedor.dart';
import '../services/database_service.dart';
import '../widgets/common.dart';

class ProveedorFormScreen extends StatefulWidget {
  final Proveedor? proveedor;
  const ProveedorFormScreen({super.key, this.proveedor});
  @override
  State<ProveedorFormScreen> createState() => _ProveedorFormScreenState();
}

class _ProveedorFormScreenState extends State<ProveedorFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.proveedor?.nombre);
  late final _telefono =
      TextEditingController(text: widget.proveedor?.telefono);
  late final _correo = TextEditingController(text: widget.proveedor?.correo);
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    final p = Proveedor(
      id: widget.proveedor?.id,
      nombre: _nombre.text.trim(),
      telefono: _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
      correo: _correo.text.trim().isEmpty ? null : _correo.text.trim(),
    );
    try {
      final db = DatabaseService.instance;
      p.id == null ? await db.insertProveedor(p) : await db.updateProveedor(p);
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
    final editando = widget.proveedor != null;
    return Scaffold(
      appBar: AppBar(
          title: Text(editando ? 'Editar proveedor' : 'Nuevo proveedor')),
      body: Centrado(
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Nombre o razón social *',
                  prefixIcon: Icon(Icons.business)),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email)),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return null;
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                    ? null
                    : 'Correo no válido';
              },
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(editando ? 'Guardar cambios' : 'Registrar'),
            ),
          ]),
        ),
      ),
    );
  }
}
