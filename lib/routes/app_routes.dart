import 'package:get/get.dart';

// Import Views
import 'package:umkm_maps_app/modules/home/views/home_view.dart';
import 'package:umkm_maps_app/modules/detail_umkm/views/detail_umkm_view.dart';
import 'package:umkm_maps_app/modules/profile_umkm/views/profile_umkm_view.dart';
import 'package:umkm_maps_app/modules/auth/views/auth_view.dart';
import 'package:umkm_maps_app/modules/admin/views/admin_view.dart';
import 'package:umkm_maps_app/modules/umkm/dashboard/views/dashboard_view.dart';
import 'package:umkm_maps_app/modules/umkm/add_product/views/add_product_view.dart';
import 'package:umkm_maps_app/modules/umkm/edit_product/views/edit_product_view.dart';

// Import Bindings
import 'package:umkm_maps_app/modules/home/bindings/home_binding.dart';

import 'package:umkm_maps_app/modules/profile_umkm/bindings/profile_umkm_binding.dart';
import 'package:umkm_maps_app/modules/auth/bindings/auth_binding.dart';
import 'package:umkm_maps_app/modules/admin/bindings/admin_binding.dart';
import 'package:umkm_maps_app/modules/umkm/dashboard/bindings/dashboard_binding.dart';
import 'package:umkm_maps_app/modules/umkm/add_product/bindings/add_product_binding.dart';
import 'package:umkm_maps_app/modules/umkm/edit_product/bindings/edit_product_binding.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String dashboardAdmin = '/dashboard-admin';
  static const String dashboardUmkm = '/dashboard-umkm';
  static const String detailUmkm = '/detail-umkm';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String profileUmkm = '/profile-umkm';

  static final pages = [
    GetPage(
      name: home,
      page: () => const HomeView(), 
      binding: HomeBinding(),
    ),
    GetPage(
      name: detailUmkm,
      page: () => const DetailUmkmView(), 
    ),
    GetPage(
      name: login,
      page: () => const AuthView(), 
      binding: AuthBinding(),
    ),
    GetPage(
      name: dashboardUmkm,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: addProduct,
      page: () => const AddProductView(),
      binding: AddProductBinding(),
    ),
    GetPage(
      name: dashboardAdmin,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: editProduct,
      page: () => const EditProductView(),
      binding: EditProductBinding(),
    ),
    GetPage(
      name: profileUmkm,
      page: () => const ProfileUmkmView(),
      binding: ProfileUmkmBinding(),
    ),
  ];
}