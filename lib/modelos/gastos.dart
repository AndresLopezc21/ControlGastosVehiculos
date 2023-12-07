import 'package:equatable/equatable.dart';

class Gasto with EquatableMixin {
  final int? id;
  final String tipoGasto;
  final double monto;
  final DateTime fecha;
  final String descripcion;
  final int categoriaId;
  final int vehiculoId;

  Gasto(
      {this.id,
      required this.tipoGasto,
      required this.monto,
      required this.fecha,
      required this.descripcion,
      required this.categoriaId,
      required this.vehiculoId});

  @override
  List<Object?> get props =>
      [id, tipoGasto, monto, fecha, descripcion, categoriaId, vehiculoId];

  @override
  bool get stringify => true;
}
