import 'package:vehiculo/blocs/blocVehiculos.dart';
import 'package:vehiculo/modelos/vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class VehiculosScreen extends StatefulWidget {
  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

Vehiculo? _selectedVehiculo;

class _VehiculosScreenState extends State<VehiculosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      body: BlocBuilder<VehiculosBlocDb, VehiculoEstado>(
        builder: (context, state) {
          var estado = context.watch<VehiculosBlocDb>().state;
          print('BlocBuilder reconstruido. Nuevo estado: $estado');

          // Check if there is an error
          if (state.error.isNotEmpty) {
            // Show Snackbar for the error
            _mostrarSnackBar(state.error);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: estado.vehiculos.isEmpty
                      ? Center(
                          child: Text('No hay vehículos'),
                        )
                      : ListView.builder(
                          itemCount: estado.vehiculos.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                '${estado.vehiculos[index].marca} - ${estado.vehiculos[index].modelo}',
                              ),
                              subtitle: Text(
                                'Año: ${estado.vehiculos[index].anio} - Color: ${estado.vehiculos[index].color}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [],
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedVehiculo = estado.vehiculos[index];
                                });
                              },
                            );
                          },
                        ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Color.fromARGB(255, 245, 88, 68),
                    onPressed: () {
                      if (_selectedVehiculo != null) {
                        _mostrarDialogoEditarVehiculo(
                            context, _selectedVehiculo!);
                      } else {
                        // Mostrar un mensaje o realizar alguna acción cuando no se ha seleccionado un vehículo.
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      if (_selectedVehiculo != null) {
                        _mostrarDialogoEliminarVehiculo(
                            context, _selectedVehiculo!);
                      } else {
                        // Mostrar un mensaje o realizar alguna acción cuando no se ha seleccionado un vehículo.
                      }
                    },
                  ),
                  SizedBox(width: 16.0), // Ajusta según el espacio deseado
                  FloatingActionButton(
                    backgroundColor: Color.fromARGB(255, 170, 5, 5),
                    onPressed: () {
                      _mostrarDialogoAgregarVehiculo(context);
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String formatYearDate(DateTime date) {
    return DateFormat('yyyy').format(date);
  }

  void _mostrarDialogoEditarVehiculo(BuildContext context, Vehiculo vehiculo) {
    TextEditingController marcaController =
        TextEditingController(text: vehiculo.marca);
    TextEditingController placaController =
        TextEditingController(text: vehiculo.placa);
    TextEditingController modeloController =
        TextEditingController(text: vehiculo.modelo);
    TextEditingController anioController =
        TextEditingController(text: vehiculo.anio);
    TextEditingController colorController =
        TextEditingController(text: vehiculo.color);

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
                        'Editar Vehículo',
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
                    decoration: InputDecoration(labelText: 'ID'),
                    controller:
                        TextEditingController(text: vehiculo.id.toString()),
                    enabled: false,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Marca'),
                    controller: marcaController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Placa'),
                    controller: placaController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Modelo'),
                    controller: modeloController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Año'),
                    controller: anioController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Color'),
                    controller: colorController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<VehiculosBlocDb>().add(
                                UpdateVehiculo(
                                  vehiculo: Vehiculo(
                                    id: vehiculo.id,
                                    placa: placaController.text,
                                    marca: marcaController.text,
                                    modelo: modeloController.text,
                                    anio: anioController.text,
                                    color: colorController.text,
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
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
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

  void _mostrarDialogoEliminarVehiculo(
      BuildContext context, Vehiculo vehiculo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Vehículo'),
          content: Text('¿Estás seguro de que quieres eliminar este vehículo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              style: TextButton.styleFrom(
                primary: Colors.red, // Color del texto del botón
              ),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para eliminar el vehículo
                context.read<VehiculosBlocDb>().add(
                      DeleteVehiculo(
                        vehiculo: vehiculo,
                      ),
                    );
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Color de fondo del botón
              ),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoAgregarVehiculo(BuildContext context) {
    TextEditingController marcaController = TextEditingController();
    TextEditingController placaController = TextEditingController();
    TextEditingController modeloController = TextEditingController();
    TextEditingController anioController = TextEditingController();
    TextEditingController colorController = TextEditingController();

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
                        'Nuevo Vehículo',
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
                    decoration: InputDecoration(labelText: 'Marca'),
                    controller: marcaController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Placa'),
                    controller: placaController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Modelo'),
                    controller: modeloController,
                  ),
                  // TextField(
                  //   decoration: InputDecoration(labelText: 'Año'),
                  //   controller: anioController,
                  // ),
                  DateTimeField(
                    decoration: InputDecoration(labelText: 'Año'),
                    format: DateFormat("yyyy"),
                    initialValue: DateTime.now(),
                    onChanged: (date) {
                      print('date: $date');
                      setState(() {
                        if (date != null) {
                          var selectedDate = date;
                          anioController.text = formatYearDate(selectedDate);
                        }
                      });
                    },
                    onShowPicker: (context, currentValue) async {
                      final date = await showDialog<DateTime>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Seleccione un Año'),
                            content: Container(
                              height: 200,
                              width: 200,
                              child: YearPicker(
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                                selectedDate: currentValue ?? DateTime.now(),
                                onChanged: (DateTime value) {
                                  setState(() {
                                    currentValue = value;
                                    anioController.text = value.year.toString();
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );

                      return date;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Color'),
                    controller: colorController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<VehiculosBlocDb>().add(
                                AddVehiculo(
                                  vehiculo: Vehiculo(
                                    marca: marcaController.text,
                                    placa: placaController.text,
                                    modelo: modeloController.text,
                                    anio: anioController.text,
                                    color: colorController.text,
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
                      TextButton(
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

  void _mostrarSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
