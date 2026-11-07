import 'package:flutter/material.dart';

/// Limita el ancho del contenido para que se vea bien en pantallas grandes.
class Centrado extends StatelessWidget {
  final Widget child;
  const Centrado({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720), child: child),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String mensaje;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.titulo,
      required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 72, color: c.primary.withValues(alpha: .4)),
          const SizedBox(height: 12),
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600)),
        ]),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final Object error;
  const ErrorState(this.error, {super.key});
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.error_outline, titulo: 'Ocurrió un error', mensaje: '$error');
}

void mostrarMensaje(BuildContext context, String texto, {bool error = false}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Row(children: [
      Icon(error ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white),
      const SizedBox(width: 12),
      Expanded(child: Text(texto)),
    ]),
    backgroundColor: error ? Colors.red.shade700 : Colors.teal.shade700,
  ));
}

Future<bool> confirmar(BuildContext context,
    {required String titulo, required String mensaje}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red, minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar')),
      ],
    ),
  );
  return r ?? false;
}
