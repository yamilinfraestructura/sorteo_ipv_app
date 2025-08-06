import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sorteo_ipv_app/src/data/models/participantes_model.dart';
import 'package:sorteo_ipv_app/src/domain/models/ganador_model.dart';
import 'package:sorteo_ipv_app/src/domain/models/manzana_model.dart';

class GanadoresController extends GetxController {
  var ganadores = <GanadorModel>[].obs;
  var isLoading = false.obs;
  // Usaremos un StreamSubscription para cancelar la escucha cuando el controlador se cierre
  // StreamSubscription? _ganadoresSubscription;

  @override
  void onInit() {
    super.onInit();
    // Escuchar los ganadores en tiempo real apenas se inicialice el controlador
    listenToGanadores();
  }

  // @override
  // void onClose() {
  //   _ganadoresSubscription?.cancel(); // Cancelar la suscripción al cerrar el controlador
  //   super.onClose();
  // }

  // --- Método para escuchar los datos de Firestore en tiempo real ---
  void listenToGanadores() {
    isLoading.value = true;
    // _ganadoresSubscription?.cancel(); // Cancelar cualquier suscripción anterior

    // Escuchar cambios en la colección 'ganadores'
    FirebaseFirestore.instance
        .collection('ganadores')
        .orderBy('fechaSorteo', descending: true) // Opcional: ordenar por fecha
        .snapshots() // <--- ¡Aquí está el cambio clave para la reactividad!
        .listen(
          (snapshot) {
            ganadores.value = snapshot.docs
                .map((doc) => GanadorModel.fromMap(doc.id, doc.data()))
                .toList();
            isLoading.value = false;
          },
          onError: (error) {
            isLoading.value = false;
            Get.snackbar(
              'Error',
              'Hubo un problema al cargar los ganadores en tiempo real.',
            );
            print('Error al escuchar ganadores: $error');
          },
        );
  }

  // Método para obtener los detalles completos del participante y la manzana
  Future<Map<String, dynamic>> obtenerDetalles(GanadorModel ganador) async {
    final participanteDoc = await FirebaseFirestore.instance
        .collection('participantes')
        .doc(ganador.participanteId)
        .get();

    final manzanaDoc = await FirebaseFirestore.instance
        .collection('manzanas')
        .doc(ganador.manzanaId)
        .get();

    return {
      'participante': ParticipanteModel.fromMap(
        participanteDoc.data()!,
        id: participanteDoc.id,
      ),
      'manzana': ManzanaModel.fromMap(manzanaDoc.id, manzanaDoc.data()!),
    };
  }
}
