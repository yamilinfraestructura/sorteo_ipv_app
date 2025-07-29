// ignore: depend_on_referenced_packages
import 'package:get/get.dart';

//Importación de archivos necesarios
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/home_screen.dart';

class AppRoutes {
  //static const initial = '/';
  //static const login = '/login';
  //static const register = '/register';
  static const home = '/';

  static final routes = [
    //GetPage(name: initial, page: () => const InitialScreen()),
    //GetPage(name: login, page: () => const LoginScreen()),
    //GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: '/', page: () => const HomeScreen()),
  ];
}
