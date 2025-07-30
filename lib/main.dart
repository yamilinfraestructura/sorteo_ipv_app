import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';

//Importación de Archivos
import 'package:sorteo_ipv_app/src/config/routers/app_routes.dart';
import 'package:sorteo_ipv_app/src/config/bindings/app_binding.dart';

void main() => runApp(const MyApp());

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
