import 'package:flutter/material.dart';

import '../models/proveedor.dart';
import '../services/database_service.dart';
import '../widgets/common.dart';
import 'proveedor_form_screen.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});
  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final _db = DatabaseService.instance;
  late Future<List<Proveedor>> _futuro = _db.getProveedores();

  void _recargar() {
    setState(() {
      _futuro = _db.getProveedores();
    });
  }

  Future<void> _abrirForm([Proveedor? p]) async {
    final ok = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => ProveedorFormScreen(proveedor: p)));
    if (ok == true) {
      _recargar();
      if (mounted) {
        mostrarMensaje(context,
            p == null ? 'Proveedor registrado' : 'Proveedor actualizado');
      }
    }
  }

  Future<void> _eliminar(Proveedor p) async {
    if (!await confirmar(context,
        titulo: 'Eliminar proveedor',
        mensaje: '¿Deseas eliminar a "${p.nombre}"?')) {
      return;
    }
    try {
      await _db.deleteProveedor(p.id!);
      _recargar();
      if (mounted) mostrarMensaje(context, 'Proveedor eliminado');
    } on ProveedorConProductosException catch (e) {
      if (mounted) mostrarMensaje(context, e.toString(), error: true);
    } catch (e) {
      if (mounted) {
        mostrarMensaje(context, 'No se pudo eliminar: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Proveedores')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _abrirForm(),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
        ),
        body: Centrado(
          child: FutureBuilder<List<Proveedor>>(
            future: _futuro,
            builder: (context, snap) {
              if (snap.hasError) return ErrorState(snap.error!);
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final lista = snap.data!;
              if (lista.isEmpty) {
                return const EmptyState(
                    icon: Icons.local_shipping_outlined,
                    titulo: 'Aún no hay proveedores',
                    mensaje: 'Toca "Nuevo" para registrar el primero.');
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: lista.length,
                itemBuilder: (_, i) {
                  final p = lista[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                      leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withValues(alpha: .12),
                          child: Text(p.nombre[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold))),
                      title: Text(p.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((p.telefono ?? '').isNotEmpty)
                              Row(children: [
                                const Icon(Icons.phone, size: 14),
                                const SizedBox(width: 6),
                                Text(p.telefono!),
                              ]),
                            if ((p.correo ?? '').isNotEmpty)
                              Row(children: [
                                const Icon(Icons.email, size: 14),
                                const SizedBox(width: 6),
                                Flexible(child: Text(p.correo!)),
                              ]),
                          ]),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _abrirForm(p)),
                        IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _eliminar(p)),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
}
