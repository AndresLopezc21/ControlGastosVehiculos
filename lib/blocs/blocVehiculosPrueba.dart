import 'package:bloc/bloc.dart';
import 'package:vehiculo/database/database.dart';
import 'package:vehiculo/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';

late DatabaseHelper db;

//Eventos
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

//Estados
class VehiculoEstado with EquatableMixin {
  final List<Vehiculo> vehiculos;

  VehiculoEstado._() : vehiculos = [];

  VehiculoEstado({required this.vehiculos});

  @override
  List<Object?> get props => [vehiculos];
}

//Bloc
class VehiculosBloc extends Bloc<VehiculoEvento, VehiculoEstado> {
  List<Vehiculo> _vehiculos = [];

  VehiculosBloc() : super(VehiculoEstado._()) {
    on<VehiculosInicializado>((event, emit) {
      _vehiculos.addAll(listaOriginal);
      emit(VehiculoEstado(vehiculos: _vehiculos));
    });
    on<AddVehiculo>(_addVehiculo);
    on<UpdateVehiculo>(_updateVehiculo);
    on<DeleteVehiculo>(_deleteVehiculo);
  }

  void _addVehiculo(AddVehiculo event, Emitter<VehiculoEstado> emit) {
    _vehiculos = _vehiculos.agregar(event.vehiculo);
    emit(VehiculoEstado(vehiculos: _vehiculos));
  }

  void _updateVehiculo(UpdateVehiculo event, Emitter<VehiculoEstado> emit) {
    List<Vehiculo> updatedVehiculos = List.from(state.vehiculos);
    int index = updatedVehiculos
        .indexWhere((vehiculo) => vehiculo.id == event.vehiculo.id);
    print('lista sin actualizar: $updatedVehiculos ');

    if (index != -1) {
      updatedVehiculos[index] = event.vehiculo;
      print('vehiculo actualizado: $updatedVehiculos ');
      emit(VehiculoEstado(vehiculos: updatedVehiculos));
      print('estado ${state.vehiculos}');
    } else {
      print('Vehículo no encontrado para actualizar');
    }
  }

  void _deleteVehiculo(DeleteVehiculo event, Emitter<VehiculoEstado> emit) {
    List<Vehiculo> updatedVehiculos = List.from(state.vehiculos);
    if (_vehiculos.contains(event.vehiculo)) {
      _vehiculos = _vehiculos.copiar()..remove(event.vehiculo);
      print('a eliminar; ${event.vehiculo}');
      emit(VehiculoEstado(vehiculos: _vehiculos));
      print('estado; ${state.vehiculos}');
    } else {
      print("no se encontro el vehiculo a eliminar");
    }
  }
}

final List<Vehiculo> listaOriginal = [
  Vehiculo(
      id: 1,
      marca: 'audi',
      placa: 'VSA-1234',
      modelo: 'a5',
      anio: '2002',
      color: 'rojo'),
  Vehiculo(
      id: 2,
      marca: 'chevrolet',
      placa: 'VSA-2345',
      modelo: 'camaro',
      anio: '2003',
      color: 'azul'),
];

extension MiLista<T> on List<T> {
  List<T> agregar(T elemento) => [...this, elemento];
  List<T> copiar() => [...this];
}
