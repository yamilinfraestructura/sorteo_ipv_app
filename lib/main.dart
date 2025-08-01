// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
//Importación de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:sorteo_ipv_app/firebase_options.dart';

//Importación de Archivos
import 'package:sorteo_ipv_app/src/config/routers/app_routes.dart';
import 'package:sorteo_ipv_app/src/config/bindings/app_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Inicializar la pantalla de carga nativa
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sorteador App IPV',
      initialRoute: '/',
      initialBinding: AppBinding(),
      getPages: AppRoutes.routes,
    );
  }
}
