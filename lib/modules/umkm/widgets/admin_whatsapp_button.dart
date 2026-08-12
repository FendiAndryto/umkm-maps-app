import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class AdminWhatsAppButton extends StatelessWidget {
  const AdminWhatsAppButton({super.key});

  Future<void> _openWhatsApp() async {
    const phoneNumber = '+6289520257683';
    const message = 'Halo Admin, saya ingin mengkonfirmasi pendaftaran akun UMKM saya.';
    
    final Uri url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'Error',
          'Tidak dapat membuka WhatsApp',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat membuka WhatsApp',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'admin_whatsapp_btn',
      onPressed: _openWhatsApp,
      backgroundColor: const Color(0xFF25D366), // WhatsApp Green
      foregroundColor: Colors.white,
      elevation: 4,
      tooltip: 'Hubungi Admin',
      child: const Icon(Icons.support_agent_rounded, size: 28),
    );
  }
}
