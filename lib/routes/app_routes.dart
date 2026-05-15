import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:umkm_maps_app/modules/guest/profile_umkm_view.dart';
import 'package:umkm_maps_app/modules/umkm/edit_product/edit_product_view.dart';
import '../modules/guest/home_view.dart'; 
import '../modules/guest/detail_umkm_view.dart';
import '../modules/auth/auth_view.dart';
import '../modules/umkm/dashboard/dashboard_view.dart';
import '../modules/umkm/add_product/add_product_view.dart';
import '../modules/admin/admin_view.dart';


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
      page: () => HomeView(), 
    ),
    GetPage(
      name: detailUmkm,
      page: () => DetailUmkmView(), 
    ),
    GetPage(
      name: login,
      page: () => AuthView(), 
    ),
    GetPage(
      name: dashboardUmkm,
      page: () => DashboardView(),
    ),
    GetPage(
      name: addProduct,
      page: () => AddProductView(),
    ),
    GetPage(
      name: dashboardAdmin,
      page: () => AdminView(),
    ),
    GetPage(name: editProduct,
    page: () => EditProductView()),
    GetPage(
      name: profileUmkm,
      page: () => ProfileUmkmView(), // Nanti kita buat file-nya
    ),

  ];
}