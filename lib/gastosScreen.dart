import 'package:collection/collection.dart';
import 'package:vehiculo/blocs/blocGastosDB.dart';
import 'package:vehiculo/blocs/blocCategoriasDB.dart';
import 'package:vehiculo/blocs/blocVehiculos.dart';
import 'package:vehiculo/modelos/categorias.dart';
import 'package:vehiculo/modelos/gastos.dart';
import 'package:vehiculo/modelos/vehiculos.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class GastosScreen extends StatefulWidget {
  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  int selectedVehiculoId = 0; // "Todos"
  int selectedCategoriaId = 0; // "Todos"
  Vehiculo? selectedVehiculo;
  Categoria? selectedCategoria;
  Gasto? gastoSeleccionado;
  @override
  void initState() {
    super.initState();
    context.read<VehiculosBlocDb>().add(VehiculosInicializado());
    context.read<CategoriasBloc>().add(Categoriasinicializado());
  }

  @override
  Widget build(BuildContext context) {
    var estadoGastos = context.watch<GastosBloc>().state;
    var estadoVehiculos = context.watch<VehiculosBlocDb>().state;
    var estadoCategorias = context.watch<CategoriasBloc>().state;

    double totalMonto;
    if (selectedVehiculoId == 0) {
      totalMonto =
          estadoGastos.gastos.fold(0.0, (sum, gasto) => sum + gasto.monto);
    } else {
      totalMonto = estadoGastos.gastos
          .where((gasto) => gasto.vehiculoId == selectedVehiculoId)
          .fold(0.0, (sum, gasto) => sum + gasto.monto);
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filtrar por categoría y vehículo
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar por Categoría',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.category, color: Color(0xCC002A52)),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedCategoriaId,
                            onChanged: (value) {
                              setState(() {
                                selectedCategoriaId = value ?? 0;
                              });
                            },
                            items: [
                              DropdownMenuItem<int>(
                                value: 0,
                                child: Text('Todos'),
                              ),
                              for (var categoria in estadoCategorias.categorias)
                                DropdownMenuItem<int>(
                                  value: categoria.id,
                                  child: Text(categoria.nombre),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Filtrar por Vehículo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.directions_car,
                            color: Color.fromARGB(255, 170, 5, 5)),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedVehiculoId,
                            onChanged: (value) {
                              setState(() {
                                selectedVehiculoId = value ?? 0;
                              });
                            },
                            items: [
                              DropdownMenuItem<int>(
                                value: 0,
                                child: Text('Todos'),
                              ),
                              for (var vehiculo in estadoVehiculos.vehiculos)
                                DropdownMenuItem<int>(
                                  value: vehiculo.id,
                                  child: Text(vehiculo.modelo),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botones fuera de la lista
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () {
                  // Verifica si hay un gasto seleccionado antes de editar
                  if (gastoSeleccionado != null) {
                    _mostrarDialogoEditarGasto(
                      context,
                      gastoSeleccionado!,
                      estadoVehiculos.vehiculos,
                      estadoCategorias.categorias,
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  // Verifica si hay un gasto seleccionado antes de eliminar
                  if (gastoSeleccionado != null) {
                    _mostrarDialogoEliminarGasto(context, gastoSeleccionado!);
                  }
                },
              ),
              SizedBox(width: 16.0), // Espacio entre los botones
              IconButton(
                icon: Icon(Icons.category),
                color: Colors.white,
                onPressed: () {
                  // Lógica para agregar categoría
                  _mostrarDialogoAgregarCategoria(context);
                },
              ),
              SizedBox(width: 16.0), // Espacio entre los botones
              FloatingActionButton(
                backgroundColor: Color.fromARGB(255, 170, 5, 5),
                onPressed: () {
                  // Lógica para agregar gasto
                  _mostrarDialogoAgregarGasto(context,
                      estadoVehiculos.vehiculos, estadoCategorias.categorias);
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Lista de Gastos
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: estadoGastos.gastos.isEmpty
                  ? Center(
                      child: Text('No hay gastos'),
                    )
                  : ListView.builder(
                      itemCount: filtrarGastos(estadoGastos.gastos,
                              selectedCategoriaId, selectedVehiculoId)
                          .length,
                      itemBuilder: (context, index) {
                        var gastosFiltrados = filtrarGastos(estadoGastos.gastos,
                            selectedCategoriaId, selectedVehiculoId);
                        var gasto = gastosFiltrados[index];

                        // Buscar la categoría correspondiente al gasto
                        Categoria? categoriaDelGasto = estadoCategorias
                            .categorias
                            .firstWhereOrNull((categoria) =>
                                categoria.id == gasto.categoriaId);

                        return ListTile(
                          title: Text(
                            '${categoriaDelGasto?.nombre ?? 'Sin categoría'} - ${gasto.monto}',
                          ),
                          subtitle: Text(
                            'Descripcion: ${gasto.descripcion} - Fecha: ${gasto.fecha}',
                          ),
                          onTap: () {
                            setState(() {
                              gastoSeleccionado = gasto;
                            });
                            _mostrarDialogoEditarGasto(
                              context,
                              gasto,
                              estadoVehiculos.vehiculos,
                              estadoCategorias.categorias,
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _mostrarDialogoAgregarGasto(BuildContext context,
      List<Vehiculo> vehiculos, List<Categoria> categorias) {
    TextEditingController tipoController = TextEditingController();
    TextEditingController montoController = TextEditingController();
    TextEditingController fechaController =
        TextEditingController(text: DateTime.now().toString());
    TextEditingController descripcionController = TextEditingController();
    TextEditingController categoriaController = TextEditingController();
    TextEditingController vehiculoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Agregar Gasto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 170, 5, 5),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Tipo'),
                    controller: tipoController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Monto'),
                    controller: montoController,
                  ),
                  DateTimeField(
                    decoration: InputDecoration(labelText: 'Fecha'),
                    format: DateFormat("yyyy-MM-dd"),
                    initialValue: DateTime.now(),
                    onChanged: (date) {
                      setState(() {
                        var selectedDate = date!;
                        fechaController.text = formatDate(selectedDate);
                      });
                    },
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.utc(DateTime.now().year),
                        lastDate: DateTime.now(),
                        initialDate: currentValue ?? DateTime.now(),
                      );

                      if (date != null) {
                        currentValue = DateTime.now();
                      }

                      return date;
                    },
                  ),
                  DropdownButtonFormField<Categoria>(
                    decoration: InputDecoration(labelText: 'Categoria'),
                    value: selectedCategoria,
                    items: categorias.map((Categoria categoria) {
                      return DropdownMenuItem<Categoria>(
                        value: categoria,
                        child: Text('${categoria.nombre}'),
                      );
                    }).toList(),
                    onChanged: (Categoria? nuevaCategoria) {
                      setState(() {
                        selectedCategoria = nuevaCategoria;
                      });
                    },
                    disabledHint: Text(selectedCategoria != null
                        ? '${selectedCategoria!.nombre} '
                        : 'Seleccione una categoria'),
                  ),
                  DropdownButtonFormField<Vehiculo>(
                    decoration: InputDecoration(labelText: 'Vehículo'),
                    value: selectedVehiculo,
                    items: vehiculos.map((Vehiculo vehiculo) {
                      return DropdownMenuItem<Vehiculo>(
                        value: vehiculo,
                        child: Text('${vehiculo.marca} - ${vehiculo.modelo}'),
                      );
                    }).toList(),
                    onChanged: (Vehiculo? nuevoVehiculo) {
                      setState(() {
                        selectedVehiculo = nuevoVehiculo;
                      });
                    },
                    disabledHint: Text(selectedVehiculo != null
                        ? '${selectedVehiculo!.marca} - ${selectedVehiculo!.modelo}'
                        : 'Seleccione un vehículo'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Descripción'),
                    controller: descripcionController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<GastosBloc>().add(
                                AddGasto(
                                  gasto: Gasto(
                                    // id: int.parse(idController.text),
                                    tipoGasto: tipoController.text,
                                    monto: double.parse(montoController.text),
                                    fecha: DateTime.parse(fechaController.text),
                                    descripcion: descripcionController.text,
                                    categoriaId: selectedCategoria?.id ?? 0,
                                    vehiculoId: selectedVehiculo?.id ?? 0,
                                  ),
                                  context: context,
                                ),
                              );

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 170, 5, 5),
                        ),
                        child: Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoEditarGasto(BuildContext context, Gasto gasto,
      List<Vehiculo> vehiculos, List<Categoria> categorias) {
    TextEditingController tipoController =
        TextEditingController(text: gasto.tipoGasto);
    TextEditingController montoController =
        TextEditingController(text: gasto.monto.toString());
    TextEditingController fechaController =
        TextEditingController(text: formatDate(gasto.fecha));
    TextEditingController descripcionController =
        TextEditingController(text: gasto.descripcion);

    Categoria? categoriaSeleccionada =
        categorias.firstWhereOrNull((v) => v.id == gasto.categoriaId);
    TextEditingController categoriaController = TextEditingController();

    Vehiculo? vehiculoSeleccionado =
        vehiculos.firstWhereOrNull((v) => v.id == gasto.vehiculoId);
    TextEditingController vehiculoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Editar Gasto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 170, 5, 5),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: 'Tipo'),
                    controller: tipoController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Monto'),
                    controller: montoController,
                  ),
                  DateTimeField(
                    decoration: InputDecoration(labelText: 'Fecha'),
                    format: DateFormat("yyyy-MM-dd"),
                    initialValue: DateTime.now(),
                    onChanged: (date) {
                      setState(() {
                        var selectedDate = date!;
                        fechaController.text = formatDate(selectedDate);
                      });
                    },
                    onSaved: (date) {
                      // Handle when the form is saved
                    },
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        initialDate: currentValue ?? DateTime.now(),
                      );

                      if (date != null) {
                        currentValue = DateTime.now();
                      }

                      return date;
                    },
                  ),
                  DropdownButtonFormField<Vehiculo>(
                    decoration: InputDecoration(labelText: 'Vehículo'),
                    value: vehiculoSeleccionado,
                    items: vehiculos.map((Vehiculo vehiculo) {
                      return DropdownMenuItem<Vehiculo>(
                        value: vehiculo,
                        child: Text('${vehiculo.marca} - ${vehiculo.modelo}'),
                      );
                    }).toList(),
                    onChanged: (Vehiculo? newValue) {
                      setState(() {
                        vehiculoController.text =
                            '${newValue?.marca ?? ''} - ${newValue?.id ?? 0}';
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Descripción'),
                    controller: descripcionController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<GastosBloc>().add(
                                UpdateGasto(
                                  gasto: Gasto(
                                    id: gasto.id,
                                    tipoGasto: tipoController.text,
                                    monto: double.parse(montoController.text),
                                    fecha: DateTime.parse(fechaController.text),
                                    descripcion: descripcionController.text,
                                    categoriaId: categoriaSeleccionada?.id ?? 0,
                                    vehiculoId: vehiculoSeleccionado?.id ?? 0,
                                  ),
                                ),
                              );

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 170, 5, 5),
                        ),
                        child: Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoAgregarCategoria(BuildContext context) {
    TextEditingController nombreCategoriaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Agregar Categoría',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 170, 5, 5),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Nombre de la Categoría'),
                    controller: nombreCategoriaController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<CategoriasBloc>().add(
                                AddCategoria(
                                  categoria: Categoria(
                                      nombre: nombreCategoriaController.text),
                                ),
                              );
                          print(
                              'Categoría agregada: ${nombreCategoriaController.text}');

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 170, 5, 5),
                        ),
                        child: Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoVerCategorias(
      BuildContext context, List<Categoria> categorias) {
    print(categorias);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            margin: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Categorias',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 170, 5, 5)),
                    ),
                  ),
                  if (categorias.isNotEmpty)
                    for (Categoria categoria in categorias)
                      ListTile(
                        title: Text(categoria.nombre),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            context.read<CategoriasBloc>().add(
                                  DeleteCategoria(
                                    categoria: categoria,
                                  ),
                                );

                            Navigator.of(context).pop();
                          },
                        ),
                      )
                  else
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Agrega una categoría',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoEliminarGasto(BuildContext context, Gasto gasto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Gasto'),
          content: Text('¿Estás seguro que deseas eliminar este gasto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: Text('Cancelar',
                  style: TextStyle(
                    color: Color(0xFF002A52),
                    fontWeight: FontWeight.bold,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                // Eliminar el vehículo
                context.read<GastosBloc>().add(
                      DeleteGasto(
                        gasto: gasto,
                      ),
                    );
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color rojo para indicar peligro
              ),
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminarCategoria(
      BuildContext context, Categoria categoria) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Categoría'),
          content: Text('¿Estás seguro que deseas eliminar esta categoría?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: Text('Cancelar',
                  style: TextStyle(
                    color: Color(0xFF002A52),
                    fontWeight: FontWeight.bold,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CategoriasBloc>().add(
                      DeleteCategoria(
                        categoria: categoria,
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "categoria eliminada.",
                    style: TextStyle(color: Colors.white),
                  ),
                  // backgroundColor: Colors.green,
                ));
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color rojo para indicar peligro
              ),
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Gasto> filtrarGastos(
      List<Gasto> todosLosGastos, int categoriaId, int vehiculoId) {
    if (categoriaId == 0 && vehiculoId == 0) {
      // Mostrar todos los gastos si no hay filtros aplicados
      return todosLosGastos;
    } else if (categoriaId == 0) {
      // Filtrar por vehículo si la categoría es "Todos"
      return todosLosGastos
          .where((gasto) => gasto.vehiculoId == vehiculoId)
          .toList();
    } else if (vehiculoId == 0) {
      // Filtrar por categoría si el vehículo es "Todos"
      return todosLosGastos
          .where((gasto) => gasto.categoriaId == categoriaId)
          .toList();
    } else {
      // Filtrar por ambos: categoría y vehículo
      return todosLosGastos
          .where((gasto) =>
              gasto.categoriaId == categoriaId &&
              gasto.vehiculoId == vehiculoId)
          .toList();
    }
  }
}
