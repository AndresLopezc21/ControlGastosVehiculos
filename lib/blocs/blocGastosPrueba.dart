import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehiculo/blocs/blocVehiculos.dart';
import 'package:vehiculo/database/database.dart';
import 'package:vehiculo/modelos/gastos.dart';
import 'package:vehiculo/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';

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
    on<GastosInicializado>((event, emit) {
      _gastos.addAll(listaOriginal);
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
      _gastos = _gastos.agregar(event.gasto);
      emit(GastoEstado(gastos: _gastos));
    } else {
      print("no existe vehiculo");
    }
  }

  void _updateGasto(UpdateGasto event, Emitter<GastoEstado> emit) {
    List<Gasto> updatedGastos = List.from(state.gastos);
    int index = updatedGastos.indexWhere((gasto) => gasto.id == event.gasto.id);
    print('lista sin actualizar: $updatedGastos ');

    if (index != -1) {
      updatedGastos[index] = event.gasto;
      print('Gasto actualizado: $updatedGastos ');
      emit(GastoEstado(gastos: updatedGastos));
      print('estado ${state.gastos}');
    } else {
      print('Vehículo no encontrado para actualizar');
    }
  }

  void _deleteGasto(DeleteGasto event, Emitter<GastoEstado> emit) {
    List<Gasto> updatedGastos = List.from(state.gastos);
    if (_gastos.contains(event.gasto)) {
      _gastos = _gastos.copiar()..remove(event.gasto);
      print('a eliminar; ${event.gasto}');
      emit(GastoEstado(gastos: _gastos));
      print('estado; ${state.gastos}');
    } else {
      print("no se encontro el vehiculo a eliminar");
    }
  }
}

final List<Gasto> listaOriginal = [
  Gasto(
      id: 1,
      tipoGasto: 'Gasolinera',
      monto: 100,
      fecha: DateTime(2023, 11, 15),
      descripcion: '100 en gasolinera morelos',
      categoriaId: 1,
      vehiculoId: 1),
  Gasto(
      id: 2,
      tipoGasto: 'Mecanico',
      monto: 600,
      fecha: DateTime(2023, 10, 1),
      descripcion: 'cambio de agua',
      categoriaId: 2,
      vehiculoId: 2)
];

extension MiLista<T> on List<T> {
  List<T> agregar(T elemento) => [...this, elemento];
  List<T> copiar() => [...this];
}
