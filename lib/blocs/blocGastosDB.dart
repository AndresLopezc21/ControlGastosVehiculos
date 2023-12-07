import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehiculo/blocs/blocVehiculos.dart';
import 'package:vehiculo/database/database.dart';
import 'package:vehiculo/modelos/gastos.dart';
import 'package:vehiculo/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late DatabaseHelper db;

//Eventos
sealed class GastoEvento {}

class GastosInicializado extends GastoEvento {}

class AddGasto extends GastoEvento {
  final Gasto gasto;
  final BuildContext context;

  AddGasto({required this.gasto, required this.context});
}

class UpdateGasto extends GastoEvento {
  final Gasto gasto;

  UpdateGasto({required this.gasto});
}

class DeleteGasto extends GastoEvento {
  final Gasto gasto;

  DeleteGasto({required this.gasto});
}

//Estados
class GastoEstado with EquatableMixin {
  final List<Gasto> gastos;

  GastoEstado._() : gastos = [];

  GastoEstado({required this.gastos});

  @override
  List<Object?> get props => [gastos];
}

//Bloc
class GastosBloc extends Bloc<GastoEvento, GastoEstado> {
  final BuildContext context;
  List<Gasto> _gastos = [];

  GastosBloc(this.context) : super(GastoEstado._()) {
    on<GastosInicializado>((event, emit) async {
      await DatabaseHelper().iniciarDatabase();
      _gastos = await getAllGastosFromDb();
      emit(GastoEstado(gastos: _gastos));
    });
    on<AddGasto>(_addGasto);
    on<UpdateGasto>(_updateGasto);
    on<DeleteGasto>(_deleteGasto);
  }

  void _addGasto(AddGasto event, Emitter<GastoEstado> emit) async {
    Vehiculo? vehiculo = await this
        .context
        .read<VehiculosBlocDb>()
        .getVehiculoById(event.gasto.vehiculoId);

    if (vehiculo != null) {
      try {
        await DatabaseHelper().iniciarDatabase();
        _gastos = await insertGasto(event.gasto);
        emit(GastoEstado(gastos: _gastos));
      } catch (e) {
        // emitErrorSnackBar(emit, 'Error al agregar gasto: $e');
        print('error al agregar gasto');
      }
    } else {
      print('No existe el vehiculo');
    }
  }

  void _updateGasto(UpdateGasto event, Emitter<GastoEstado> emit) async {
    Vehiculo? vehiculo = await this
        .context
        .read<VehiculosBlocDb>()
        .getVehiculoById(event.gasto.vehiculoId);

    if (vehiculo != null) {
      try {
        Gasto? editGasto = event.gasto;
        print("editGasto: $editGasto");

        if (editGasto != null) {
          _gastos = await updateGasto(event.gasto);
          emit(GastoEstado(gastos: _gastos));
          print('Gasto actualizado con éxito!');
        } else {
          // emitErrorSnackBar(emit, 'Vehículo no encontrado para actualizar.');
          print("gasto no encontrado");
        }
      } catch (e) {
        // emitErrorSnackBar(emit, 'Error al actualizar el vehículo: $e');
        print("Error al actualizar el vehiculo");
      }
    }
  }

  void _deleteGasto(DeleteGasto event, Emitter<GastoEstado> emit) async {
    try {
      List<Gasto> updatedList = await deleteGasto(event.gasto);
      emit(GastoEstado(gastos: updatedList));
      print('Gasto eliminado con éxito!');
    } catch (e) {
      // emitErrorSnackBar(emit, 'Error al eliminar el vehículo: $e');
      print("Error al borrar el gasto");
    }
  }
}

Future<List<Gasto>> getAllGastosFromDb() async {
  final Database? db = await DatabaseHelper().database;

  if (db == null) {
    print('Error: Database not initialized.');
    return [];
  }

  List<Map<String, dynamic>> data = await db.query('gastos');
  List<Gasto> listaOriginal = data.map((e) {
    return Gasto(
        id: e['ID'],
        tipoGasto: e['tipoGasto'],
        monto: double.parse(e['monto'].toString()),
        fecha: DateTime.parse(e['fecha']),
        descripcion: e['descripcion'],
        categoriaId: e['categoriaId'],
        vehiculoId: e['vehiculoId']);
  }).toList();

  return listaOriginal;
}

Future<List<Gasto>> insertGasto(Gasto gasto) async {
  final Database? db = await DatabaseHelper().database;

  if (db == null) {
    print('Error: Database not initialized.');
    return [];
  }

  await db.insert(
    'gastos',
    {
      'tipoGasto': gasto.tipoGasto,
      'monto': gasto.monto,
      'fecha': gasto.fecha.toIso8601String(),
      'descripcion': gasto.descripcion,
      'categoriaId': gasto.categoriaId,
      'vehiculoId': gasto.vehiculoId
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  List<Map<String, dynamic>> data = await db.query('gastos');
  List<Gasto> listaOriginal = data.map((e) {
    return Gasto(
        id: e['ID'],
        tipoGasto: e['tipoGasto'],
        monto: double.parse(e['monto'].toString()),
        fecha: DateTime.parse(e['fecha']),
        descripcion: e['descripcion'],
        categoriaId: e['categoriaId'],
        vehiculoId: e['vehiculoId']);
  }).toList();

  return listaOriginal;
}

Future<Gasto?> getGastoById(int? id) async {
  final Database? db = await DatabaseHelper().database;

  if (db == null) {
    print('Error: Database not initialized.');
    return null;
  }

  if (id != null) {
    List<Map<String, dynamic>> data = await db.query(
      'gastos',
      where: 'ID = ?',
      whereArgs: [id],
    );

    if (data.isNotEmpty) {
      Map<String, dynamic> gastoData = data.first;
      return Gasto(
          id: gastoData['ID'],
          tipoGasto: gastoData['tipoGasto'],
          monto: gastoData['monto'],
          fecha: gastoData['fecha'],
          descripcion: gastoData['descripcion'],
          categoriaId: gastoData['categoriaId'],
          vehiculoId: gastoData['vehiculoId']);
    } else {
      print('Gasto con id $id no encontrado.');
      return null;
    }
  }
}

Future<List<Gasto>> updateGasto(Gasto? gasto) async {
  final Database? db = await DatabaseHelper().database;
  print("entro al update");
  if (gasto == null) {
    print("no hay gasto");
    return [];
  }

  if (db == null) {
    print('Error: Database not initialized.');
    return [];
  }

  await db.update(
    'gastos',
    {
      'tipoGasto': gasto.tipoGasto,
      'monto': gasto.monto,
      'fecha': gasto.fecha.toIso8601String(),
      'descripcion': gasto.descripcion,
      'categoriaId': gasto.categoriaId,
      'vehiculoId': gasto.vehiculoId
    },
    where: 'ID = ?',
    whereArgs: [gasto.id],
  );

  List<Map<String, dynamic>> data = await db.query('gastos');
  List<Gasto> listaOriginal = data.map((e) {
    return Gasto(
        id: e['ID'],
        tipoGasto: e['tipoGasto'],
        monto: double.parse(e['monto'].toString()),
        fecha: DateTime.parse(e['fecha']),
        descripcion: e['descripcion'],
        categoriaId: e['categoriaId'],
        vehiculoId: e['vehiculoId']);
  }).toList();

  return listaOriginal;
}

Future<List<Gasto>> deleteGasto(Gasto gasto) async {
  final Database? db = await DatabaseHelper().database;

  if (db == null) {
    print('Error: Database not initialized.');
    return [];
  }

  await db.delete(
    'gastos',
    where: 'ID = ?',
    whereArgs: [gasto.id],
  );

  List<Map<String, dynamic>> data = await db.query('gastos');
  List<Gasto> updatedList = data.map((e) {
    return Gasto(
        id: e['ID'],
        tipoGasto: e['tipoGasto'],
        monto: double.parse(e['monto'].toString()),
        fecha: DateTime.parse(e['fecha']),
        descripcion: e['descripcion'],
        categoriaId: e['categoriaId'],
        vehiculoId: e['vehiculoId']);
  }).toList();

  return updatedList;
}
