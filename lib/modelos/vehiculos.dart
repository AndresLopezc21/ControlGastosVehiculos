import 'package:equatable/equatable.dart';

class Vehiculo with EquatableMixin {
  final int? id;
  final String marca;
  final String placa;
  final String modelo;
  final String anio;
  final String color;

  Vehiculo({
    this.id,
    required this.marca,
    required this.placa,
    required this.modelo,
    required this.anio,
    required this.color,
  });

  @override
  List<Object?> get props => [id, marca, placa, modelo, anio, color];

  @override
  bool get stringify => true;
}
