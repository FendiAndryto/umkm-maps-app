import 'package:get/get.dart';
import '../controllers/profile_umkm_controller.dart';

class ProfileUmkmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileUmkmController>(() => ProfileUmkmController());
  }
}
