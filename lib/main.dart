import 'package:vehiculo/CategoriasDialog.dart';
import 'package:vehiculo/blocs/blocCategoriasDB.dart';
import 'package:vehiculo/blocs/blocGastosDB.dart';
import 'package:vehiculo/blocs/blocVehiculos.dart';
import 'package:vehiculo/database/database.dart';
import 'package:vehiculo/gastosScreen.dart';
import 'package:vehiculo/modelos/categorias.dart';
import 'package:vehiculo/vehiculosScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehiculo/modelos/vehiculos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.iniciarDatabase();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    //InicioScreen(),
    VehiculosScreen(),
    GastosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VehiculosBlocDb>(
          create: (context) => VehiculosBlocDb()..add(VehiculosInicializado()),
        ),
        BlocProvider<CategoriasBloc>(
          create: (context) => CategoriasBloc()..add(Categoriasinicializado()),
        ),
        BlocProvider<GastosBloc>(
          create: (context) => GastosBloc(context)..add(GastosInicializado()),
        ),
      ],
      child: MaterialApp(
        title: 'Control de Gastos de Vehículos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFF002A52, <int, Color>{
            50: Color.fromARGB(255, 170, 5, 5),
            100: Color.fromARGB(255, 170, 5, 5),
            200: Color.fromARGB(255, 170, 5, 5),
            300: Color.fromARGB(255, 170, 5, 5),
            400: Color.fromARGB(255, 170, 5, 5),
            500: Color.fromARGB(255, 170, 5, 5),
            600: Color.fromARGB(255, 170, 5, 5),
            700: Color.fromARGB(255, 170, 5, 5),
            800: Color.fromARGB(255, 170, 5, 5),
            900: Color.fromARGB(255, 170, 5, 5),
          }),
          primaryColor: Color.fromARGB(255, 170, 5, 5),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Control de gastos y vehiculos'),
            backgroundColor: Color.fromARGB(255, 170, 5, 5),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 170, 5, 5),
                  ),
                  child: Text(
                    'Menú',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                /*ListTile(
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap: () {
            // Agrega aquí la lógica que deseas para el elemento "Inicio"
            Navigator.pop(context);
          },
        ),*/
                ListTile(
                  leading: Icon(Icons.directions_car),
                  title: Text('Vehículos'),
                  onTap: () {
                    setState(() {
                      _currentIndex =
                          0; // Cambiar a la posición del ítem "Vehículos"
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Gastos'),
                  onTap: () {
                    setState(() {
                      _currentIndex =
                          1; // Cambiar a la posición del ítem "Gastos"
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          body: _screens[_currentIndex],
        ),
      ),
    );
  }
}

void mostrarDialogoVerCategorias(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
    },
  );
}
