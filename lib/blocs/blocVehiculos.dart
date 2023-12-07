import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:vehiculo/database/database.dart';
import 'package:vehiculo/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late DatabaseHelper db;

sealed class VehiculoEvento {}

class VehiculosInicializado extends VehiculoEvento {}

class AddVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  AddVehiculo({required this.vehiculo});
}

class UpdateVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  UpdateVehiculo({required this.vehiculo});
}

class DeleteVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  DeleteVehiculo({required this.vehiculo});
}

class ObtenerVehiculos extends VehiculoEvento {
  final Vehiculo vehiculo;

  ObtenerVehiculos({required this.vehiculo});
}

//Estados
class VehiculoEstado with EquatableMixin {
  final List<Vehiculo> vehiculos;
  String error = "";

  VehiculoEstado._() : vehiculos = [];

  VehiculoEstado({required this.vehiculos, this.error = ""});

  @override
  List<Object?> get props => [vehiculos];
}

class MockVehiculosBlocDb extends Mock implements VehiculosBlocDb {}

//Bloc
class VehiculosBlocDb extends Bloc<VehiculoEvento, VehiculoEstado> {
  List<Vehiculo> _vehiculos = [];

  VehiculosBlocDb() : super(VehiculoEstado._()) {
    on<VehiculosInicializado>((event, emit) async {
      await DatabaseHelper().iniciarDatabase();
      _vehiculos = await getAllVehiculosFromDb();
      emit(VehiculoEstado(vehiculos: _vehiculos));
    });
    on<AddVehiculo>(_addVehiculo);
    on<UpdateVehiculo>(_updateVehiculo);
    on<DeleteVehiculo>(_deleteVehiculo);
  }

  void _addVehiculo(AddVehiculo event, Emitter<VehiculoEstado> emit) async {
    try {
      await DatabaseHelper().iniciarDatabase();
      _vehiculos = await insertVehiculo(event.vehiculo);
      emit(VehiculoEstado(vehiculos: _vehiculos));
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al agregar vehículo: $e');
    }
  }

  void _updateVehiculo(
      UpdateVehiculo event, Emitter<VehiculoEstado> emit) async {
    try {
      Vehiculo? editvehiculo = await getVehiculoByPlaca(event.vehiculo.placa);
      print("editVehiculo: $editvehiculo");

      if (editvehiculo != null) {
        _vehiculos = await updateVehiculo(event.vehiculo);
        emit(VehiculoEstado(vehiculos: _vehiculos));
        print('Vehículo actualizado con éxito!');
      } else {
        emitErrorSnackBar(emit, 'Vehículo no encontrado para actualizar.');
      }
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al actualizar el vehículo: $e');
    }
  }

  void _deleteVehiculo(
      DeleteVehiculo event, Emitter<VehiculoEstado> emit) async {
    try {
      List<Vehiculo> updatedList = await deleteVehiculo(event.vehiculo);
      emit(VehiculoEstado(vehiculos: updatedList));
      print('Vehículo eliminado con éxito!');
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al eliminar el vehículo: $e');
    }
  }

  void _getVehiculos(
      ObtenerVehiculos event, Emitter<VehiculoEstado> emit) async {
    try {
      List<Vehiculo> vehiculos = await obtenerVehiculos();
      print("Vehículos de filtro obtenidos");
      emit(VehiculoEstado(vehiculos: vehiculos));
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al obtener vehículos: $e');
    }
  }

  void emitErrorSnackBar(Emitter<VehiculoEstado> emit, String errorMessage) {
    emit(VehiculoEstado(
        vehiculos: state.vehiculos,
        error: errorMessage)); // Mantener el estado actual
  }

  Future<List<Vehiculo>> getAllVehiculosFromDb() async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    List<Map<String, dynamic>> data = await db.query('vehiculos');
    List<Vehiculo> listaOriginal = data.map((e) {
      return Vehiculo(
          id: e['ID'],
          marca: e['marca'],
          placa: e['placa'],
          modelo: e['modelo'],
          anio: e['anio'],
          color: e['color']);
    }).toList();

    return listaOriginal;
  }

  Future<List<Vehiculo>> insertVehiculo(Vehiculo vehiculo) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }
    if (getVehiculoByPlaca(vehiculo.placa) == null) {
      return [];
    }
    await db.insert(
      'vehiculos',
      {
        'marca': vehiculo.marca,
        'placa': vehiculo.placa,
        'modelo': vehiculo.modelo,
        'anio': vehiculo.anio,
        'color': vehiculo.color
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    List<Map<String, dynamic>> data = await db.query('vehiculos');
    List<Vehiculo> listaOriginal = data.map((e) {
      return Vehiculo(
        id: e['ID'],
        marca: e['marca'],
        placa: e['placa'],
        modelo: e['modelo'],
        anio: e['anio'],
        color: e['color'],
      );
    }).toList();

    return listaOriginal;
  }

  Future<Vehiculo?> getVehiculoById(int id) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return null;
    }

    List<Map<String, dynamic>> data = await db.query(
      'vehiculos',
      where: 'ID = ?',
      whereArgs: [id],
    );

    if (data.isNotEmpty) {
      Map<String, dynamic> vehiculoData = data.first;
      return Vehiculo(
        id: vehiculoData['ID'],
        marca: vehiculoData['marca'],
        placa: vehiculoData['placa'],
        modelo: vehiculoData['modelo'],
        anio: vehiculoData['anio'],
        color: vehiculoData['color'],
      );
    } else {
      print('Vehículo con id $id no encontrado.');
      return null;
    }
  }

  Future<Vehiculo?> getVehiculoByPlaca(String placa) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return null;
    }

    List<Map<String, dynamic>> data = await db.query(
      'vehiculos',
      where: 'placa = ?',
      whereArgs: [placa],
    );

    if (data.isNotEmpty) {
      Map<String, dynamic> vehiculoData = data.first;
      return Vehiculo(
        id: vehiculoData['ID'],
        marca: vehiculoData['marca'],
        placa: vehiculoData['placa'],
        modelo: vehiculoData['modelo'],
        anio: vehiculoData['anio'],
        color: vehiculoData['color'],
      );
    } else {
      print('Vehículo con modelo $placa no encontrado.');
      return null;
    }
  }

  Future<List<Vehiculo>> updateVehiculo(Vehiculo? vehiculo) async {
    final Database? db = await DatabaseHelper().database;
    print("entro al update");
    if (vehiculo == null) {
      print("no hay vehiculo");
      return [];
    }

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    await db.update(
      'vehiculos',
      {
        'marca': vehiculo.marca,
        'placa': vehiculo.placa,
        'modelo': vehiculo.modelo,
        'anio': vehiculo.anio,
        'color': vehiculo.color
      },
      where: 'ID = ?',
      whereArgs: [vehiculo.id],
    );

    List<Map<String, dynamic>> data = await db.query('vehiculos');
    List<Vehiculo> listaOriginal = data.map((e) {
      return Vehiculo(
        id: e['ID'],
        marca: e['marca'],
        placa: e['placa'],
        modelo: e['modelo'],
        anio: e['anio'],
        color: e['color'],
      );
    }).toList();

    return listaOriginal;
  }

  Future<List<Vehiculo>> deleteVehiculo(Vehiculo vehiculo) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    await db.delete(
      'vehiculos',
      where: 'ID = ?',
      whereArgs: [vehiculo.id],
    );

    List<Map<String, dynamic>> data = await db.query('vehiculos');
    List<Vehiculo> updatedList = data.map((e) {
      return Vehiculo(
        id: e['ID'],
        marca: e['marca'],
        placa: e['placa'],
        modelo: e['modelo'],
        anio: e['anio'],
        color: e['color'],
      );
    }).toList();

    return updatedList;
  }
}

Future<List<Vehiculo>> obtenerVehiculos() async {
  final Database? db = await DatabaseHelper().database;
  if (db == null) {
    print('Error: Database not initialized.');
    return [];
  }
  try {
    final List<Map<String, dynamic>> maps = await db.query('vehiculos');

    return List.generate(maps.length, (index) {
      return Vehiculo(
        id: maps[index]['ID'],
        marca: maps[index]['marca'],
        placa: maps[index]['placa'],
        modelo: maps[index]['modelo'],
        anio: maps[index]['anio'],
        color: maps[index]['color'],
      );
    });
  } catch (e) {
    print('Error al obtener vehículos: $e');
    throw Exception('Error al obtener vehículos: $e');
  }
}
