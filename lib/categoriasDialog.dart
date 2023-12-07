import 'package:vehiculo/modelos/categorias.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/blocCategoriasDB.dart';

class CategoriasDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocBuilder<CategoriasBloc, CategoriasEstado>(
        builder: (context, state) {
          if (state is CategoriasEstado) {
            List<Categoria> categorias = state.categorias;

            return SingleChildScrollView(
              child: Column(
                children: [
                  for (Categoria categoria in categorias)
                    ListTile(
                      title: Text(categoria.nombre),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Handle delete category action
                          context.read<CategoriasBloc>().add(
                                DeleteCategoria(
                                  categoria: categoria,
                                ),
                              );
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  static void mostrarDialogoVerCategorias(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CategoriasDialog();
      },
    );
  }
}
