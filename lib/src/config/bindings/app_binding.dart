// ignore: depend_on_referenced_packages
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/cargar_manzanas_screen/controllers/manzanas_import_controller.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/carga_participantes_controller.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/ganador_controller.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/nuevo_sorteador_controller.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/triple_sorteador_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CargaParticipantesController());
    Get.put(ManzanasImportController());
    Get.put(TripleSorteadorController());
    Get.put(SorteoController());
    Get.put(GanadoresController());
  }
}
