import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/productos_screen.dart';
import 'screens/proveedores_screen.dart';

class Routes {
  static const dashboard = '/';
  static const productos = '/productos';
  static const proveedores = '/proveedores';

  static final Map<String, WidgetBuilder> table = {
    dashboard: (_) => const DashboardScreen(),
    productos: (_) => const ProductosScreen(),
    proveedores: (_) => const ProveedoresScreen(),
  };
}
