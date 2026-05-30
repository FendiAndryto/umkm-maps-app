import 'package:get/get.dart';
import '../controllers/detail_umkm_controller.dart';

class DetailUmkmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailUmkmController>(
      () => DetailUmkmController(),
      tag: Get.arguments?.toString(),
    );
  }
}
