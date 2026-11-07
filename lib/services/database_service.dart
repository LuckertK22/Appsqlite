import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/producto.dart';
import '../models/proveedor.dart';

/// Se lanza cuando se intenta eliminar un proveedor con productos asociados.
class ProveedorConProductosException implements Exception {
  final int cantidad;
  ProveedorConProductosException(this.cantidad);
  @override
  String toString() =>
      'No se puede eliminar: el proveedor tiene $cantidad producto(s) asociado(s).';
}

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final path = join(await getDatabasesPath(), 'inventario.db');
    return openDatabase(
      path,
      version: 1,
      // Activa y respeta las claves foráneas en cada conexión.
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE proveedores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            telefono TEXT,
            correo TEXT
          )''');
        await db.execute('''
          CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            stock INTEGER NOT NULL,
            proveedor_id INTEGER NOT NULL,
            FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
              ON DELETE RESTRICT
          )''');
      },
    );
  }

  // ---------- Proveedores ----------
  Future<List<Proveedor>> getProveedores() async {
    final db = await database;
    final rows =
        await db.query('proveedores', orderBy: 'nombre COLLATE NOCASE');
    return rows.map(Proveedor.fromMap).toList();
  }

  Future<int> insertProveedor(Proveedor p) async =>
      (await database).insert('proveedores', p.toMap());

  Future<int> updateProveedor(Proveedor p) async => (await database)
      .update('proveedores', p.toMap(), where: 'id = ?', whereArgs: [p.id]);

  Future<int> contarProductosDeProveedor(int id) async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM productos WHERE proveedor_id = ?', [id])) ??
        0;
  }

  Future<void> deleteProveedor(int id) async {
    final n = await contarProductosDeProveedor(id);
    if (n > 0) throw ProveedorConProductosException(n);
    await (await database)
        .delete('proveedores', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Productos ----------
  /// Consulta con INNER JOIN para traer también el nombre del proveedor.
  Future<List<Producto>> getProductos({String filtro = ''}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT p.id, p.nombre, p.precio, p.stock, p.proveedor_id,
             pr.nombre AS proveedor_nombre
      FROM productos p
      INNER JOIN proveedores pr ON pr.id = p.proveedor_id
      WHERE p.nombre LIKE ?
      ORDER BY p.nombre COLLATE NOCASE
    ''', ['%${filtro.trim()}%']);
    return rows.map(Producto.fromMap).toList();
  }

  Future<int> insertProducto(Producto p) async =>
      (await database).insert('productos', p.toMap());

  Future<int> updateProducto(Producto p) async => (await database)
      .update('productos', p.toMap(), where: 'id = ?', whereArgs: [p.id]);

  Future<void> deleteProducto(int id) async => (await database)
      .delete('productos', where: 'id = ?', whereArgs: [id]);

  // ---------- Totales ----------
  Future<int> totalProductos() async => Sqflite.firstIntValue(
          await (await database).rawQuery('SELECT COUNT(*) FROM productos')) ??
      0;

  Future<int> totalProveedores() async => Sqflite.firstIntValue(await (await database)
          .rawQuery('SELECT COUNT(*) FROM proveedores')) ??
      0;
}
