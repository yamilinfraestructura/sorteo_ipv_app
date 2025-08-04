// ignore: depend_on_referenced_packages
import 'package:get/get.dart';

//Importación de archivos necesarios
import 'package:sorteo_ipv_app/src/presentation/screens/screen.dart';

class AppRoutes {
  //static const initial = '/';
  //static const login = '/login';
  //static const register = '/register';
  static const home = '/';

  static final routes = [
    GetPage(name: '/', page: () => const HomeScreen()),
    GetPage(
      name: '/importar-participantes',
      page: () => const ImportarParticipantesScreen(),
    ),
    GetPage(name: '/cargar-manzanas', page: () => const CargarManzanasScreen()),
  ];
}
