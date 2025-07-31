// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
// Importación de Archivos
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CargaParticipantesController());
    //Get.put(SorteadorController(items: []), tag: 'participante');
    //Get.put(ImportPadronesController());
    //Get.put(SearchParticipanteController());
    //Get.put(ListGanadoresController());
    //Get.put(ExportGanadoresController());
    //Get.put(LoginController(), permanent: true);
    //Get.put(SettingsController(), permanent: true);
  }
}
