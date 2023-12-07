import 'package:equatable/equatable.dart';

class Categoria with EquatableMixin {
  final int? id;
  final String nombre;

  Categoria({this.id, required this.nombre});

  @override
  List<Object?> get props => [id, nombre];

  @override
  bool get stringify => true;
}
