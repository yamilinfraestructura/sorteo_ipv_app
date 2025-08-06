import 'package:flutter/material.dart';
// Asegúrate de que estas rutas sean correctas en tu proyecto
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/widgets/ganadores_widget.dart'; // El nuevo widget de ganadores
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/components/component.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/widgets/nuevo_sorteador_widget.dart'; // Tu componente de Drawer

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _heightScreen = MediaQuery.of(context).size.height;
    final _widthScreen = MediaQuery.of(context).size.width;

    // Determina si la pantalla es lo suficientemente ancha para mostrar los widgets lado a lado
    bool isWideScreen =
        _widthScreen > 600; // Puedes ajustar este valor según tus necesidades

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorteador de posiciones lotes - IPV 2025'),
        backgroundColor: Colors.amberAccent,
        elevation: 4,
      ),
      body: Container(
        width: _widthScreen,
        height: _heightScreen,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.amber.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isWideScreen
            ? Row(
                // Para pantallas anchas, muestra los widgets lado a lado
                children: [
                  Expanded(
                    flex: 1, // Puedes ajustar la proporción si lo necesitas
                    child: SorteoWidget(),
                  ),
                  Expanded(
                    flex: 1, // Puedes ajustar la proporción si lo necesitas
                    child: GanadoresWidget(),
                  ),
                ],
              )
            : Column(
                // Para pantallas pequeñas, muestra los widgets uno encima del otro
                children: [
                  Expanded(flex: 1, child: SorteoWidget()),
                  Expanded(flex: 1, child: GanadoresWidget()),
                ],
              ),
      ),
      endDrawer: DrawerComponent(),
    );
  }
}
