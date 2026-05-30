import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapcn_flutter/mapcn_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:umkm_maps_app/core/theme/app_colors.dart';
import 'package:umkm_maps_app/core/theme/app_theme.dart';
import 'package:umkm_maps_app/core/widgets/app_card.dart';
import 'package:umkm_maps_app/core/widgets/app_button.dart';
import 'package:umkm_maps_app/core/widgets/product_cards.dart';
import 'package:umkm_maps_app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.selectedTabIndex.value == 2) {
          return _buildMapTab();
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Sticky header with search ───────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: AppColors.surface,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                expandedHeight: 130,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.selectedTabIndex.value == 1
                                      ? 'Promo Jajanan 🔥'
                                      : 'Etalase Jajanan 🍱',
                                  style: AppTheme.headingMd,
                                ),
                                Text(
                                  controller.selectedTabIndex.value == 1
                                      ? 'Lagi diskon gede-gedean nih!'
                                      : 'Temukan jajanan favoritmu',
                                  style: AppTheme.bodySm,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: TextField(
                      onChanged: (v) => controller.searchProduct(v),
                      style: AppTheme.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'Cari jajanan enak…',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppTheme.roundedLg,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppTheme.roundedLg,
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Loading skeleton ────────────────────────────────
              if (controller.isLoading.value)
                SliverToBoxAdapter(child: _buildSkeleton()),

              if (!controller.isLoading.value) ...[
                // ── Category chips ─────────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.categories.length,
                      itemBuilder: (context, i) {
                        final cat = controller.categories[i];
                        final selected = controller.selectedCategory.value == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: selected,
                              onSelected: (_) => controller.selectCategory(cat),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              labelStyle: AppTheme.labelMd.copyWith(
                                color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: selected ? AppColors.primary : AppColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.roundedFull,
                              ),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Promo section ─────────────────────────────
                if (controller.selectedTabIndex.value == 0 && controller.promoProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: SectionHeader(
                        title: '🔥 Sedang Promo',
                        actionLabel: 'Lihat semua',
                        onAction: () => controller.selectedTabIndex.value = 1,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 232,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: controller.promoProducts.length,
                        itemBuilder: (context, i) {
                          final p = controller.promoProducts[i];
                          return Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: ProductCardVertical(
                              product: p,
                              width: 162,
                              onTap: () => Get.toNamed('/detail-umkm', arguments: p.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // ── Regular products ──────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: SectionHeader(
                      title: controller.selectedTabIndex.value == 1
                          ? 'Daftar Jajanan Promo'
                          : 'Rekomendasi Jajanan',
                    ),
                  ),
                ),

                if (controller.selectedTabIndex.value == 1
                    ? controller.promoProducts.isEmpty
                    : controller.regularProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_basket_outlined,
                              size: 56, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            controller.selectedTabIndex.value == 1
                                ? 'Belum ada promo jualan'
                                : 'Belum ada jajanan tersedia',
                            style: AppTheme.bodyMd
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final p = controller.selectedTabIndex.value == 1
                              ? controller.promoProducts[i]
                              : controller.regularProducts[i];
                          return ProductCardHorizontal(
                            product: p,
                            onTap: () => Get.toNamed('/detail-umkm', arguments: p.id),
                          );
                        },
                        childCount: controller.selectedTabIndex.value == 1
                            ? controller.promoProducts.length
                            : controller.regularProducts.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.selectedTabIndex.value,
        onTap: (index) {
          if (index == 3) {
            Get.toNamed('/login');
          } else {
            if (index == 2 && controller.selectedTabIndex.value != 2) {
              controller.initMapController();
            }
            controller.selectedTabIndex.value = index;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTheme.labelMd.copyWith(fontSize: 11),
        unselectedLabelStyle: AppTheme.labelMd.copyWith(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department_outlined),
            activeIcon: Icon(Icons.local_fire_department_rounded),
            label: 'Promo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Login',
          ),
        ],
      )),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(height: 20, width: 140),
          const SizedBox(height: 20),
          Row(
            children: List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: const AppSkeleton(width: 80, height: 36),
            )),
          ),
          const SizedBox(height: 24),
          ...List.generate(4, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: const [
                AppSkeleton(width: 80, height: 80),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(height: 16),
                      SizedBox(height: 8),
                      AppSkeleton(height: 14, width: 80),
                      SizedBox(height: 8),
                      AppSkeleton(height: 12, width: 60),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    final activeStores = controller.activeUmkmList;

    return Obx(() {
      return Stack(
        children: [
          // 1. Standard FlutterMap with Custom Mapcn Dark Theme & Red Coordinates
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.mapCenter.value,
              initialZoom: 14,
              minZoom: 2.0,
              maxZoom: 18.0,
              backgroundColor: Colors.black,
            ),
            children: [
              // Beautiful dark aesthetic filter matrix!
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(MapcnThemes.mapcnDark),
                child: TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mapcn',
                ),
              ),
              // Marker Layer drawing custom interactive red coordinate pins
              MarkerLayer(
                markers: activeStores.asMap().entries.map((entry) {
                  final index = entry.key;
                  final store = entry.value;
                  final lat = double.tryParse(store['latitude'].toString()) ?? 0.0;
                  final lng = double.tryParse(store['longitude'].toString()) ?? 0.0;
                  final latLng = LatLng(lat, lng);
                  
                  final isSelected = controller.selectedUmkmIndex.value == index;
                  
                  return Marker(
                    point: latLng,
                    width: 64,
                    height: 64,
                    alignment: Alignment.topCenter, // Align pin tip precisely to coordinate
                    child: GestureDetector(
                      onTap: () {
                        controller.animateToStore(index, latLng);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple animation circle if active
                          if (isSelected)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Container(
                                  width: 48 * value,
                                  height: 48 * value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.withValues(alpha: 0.35 * (1 - value)),
                                  ),
                                );
                              },
                            ),
                          // Drop Shadow beneath the pin
                          Positioned(
                            bottom: 6,
                            child: Container(
                              width: 10,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.45),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 2,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Premium 3D red coordinate icon with bounce transition
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            transform: Matrix4.translationValues(0, isSelected ? -8 : 0, 0),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: isSelected ? Colors.red.shade700 : Colors.red.shade500,
                              size: isSelected ? 44 : 34,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          // Core coordinate center white dot
                          Positioned(
                            top: isSelected ? 12 : 9,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: isSelected ? 10 : 8,
                              height: isSelected ? 10 : 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Floating Search/Title Bar
          Positioned(
            top: 52,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppTheme.roundedLg,
                boxShadow: AppColors.shadowMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.explore_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Peta Jajanan UMKM 📍', style: AppTheme.headingSm),
                        Text(
                          '${activeStores.length} warung terdaftar di sekitar kamu',
                          style: AppTheme.bodySm,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location_rounded, color: AppColors.primary),
                    onPressed: () => controller.determineMapCenter(),
                    tooltip: 'Lokasi Saya',
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Snapping Carousel of Registered UMKM Profile Cards
          if (activeStores.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 112,
                child: PageView.builder(
                  controller: controller.mapPageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: activeStores.length,
                  onPageChanged: (index) {
                    final store = activeStores[index];
                    final lat = double.tryParse(store['latitude'].toString()) ?? 0.0;
                    final lng = double.tryParse(store['longitude'].toString()) ?? 0.0;
                    controller.selectedUmkmIndex.value = index;
                    controller.mapCenter.value = LatLng(lat, lng);
                    try {
                      controller.mapController.move(LatLng(lat, lng), 14.5);
                    } catch (e) {
                      // Ignored
                    }
                  },
                  itemBuilder: (context, i) {
                    final store = activeStores[i];
                    final String name = store['nama_toko'] ?? 'Warung';
                    final String desc = store['deskripsi'] ?? 'Jajanan maknyus!';
                    final isSelected = controller.selectedUmkmIndex.value == i;

                    return AnimatedScale(
                      scale: isSelected ? 1.0 : 0.95,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppTheme.roundedLg,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                  ...AppColors.shadowMd,
                                ]
                              : AppColors.shadowMd,
                          border: Border.all(
                            color: isSelected ? Colors.red.withValues(alpha: 0.5) : AppColors.border,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primarySurface,
                                image: (store['foto_profil'] != null &&
                                        store['foto_profil']
                                            .toString()
                                            .isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(store['foto_profil']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (store['foto_profil'] == null ||
                                      store['foto_profil']
                                          .toString()
                                          .isEmpty)
                                  ? const Icon(Icons.storefront_rounded,
                                      size: 22, color: AppColors.primary)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    name,
                                    style: AppTheme.headingSm,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    desc,
                                    style: AppTheme.bodySm,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppButton(
                              label: 'Detail',
                              size: AppButtonSize.sm,
                              fullWidth: false,
                              onPressed: () => Get.toNamed('/profile-umkm',
                                  arguments: store['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      );
    });
  }
}
