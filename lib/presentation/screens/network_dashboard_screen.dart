// ========================================
// network_dashboard_screen.dart - لوحة تحكم الشبكة والمزامنة
// نظام إدارة التعليم / Education Management System
// ========================================

import 'package:flutter/material.dart';
import '../../core/services/network_service.dart';
import '../../core/services/hotspot_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/utils/ui_utils.dart';

class NetworkDashboardScreen extends StatefulWidget {
  const NetworkDashboardScreen({super.key});

  @override
  State<NetworkDashboardScreen> createState() => _NetworkDashboardScreenState();
}

class _NetworkDashboardScreenState extends State<NetworkDashboardScreen> {
  final NetworkService _network = NetworkService();
  final HotspotService _hotspot = HotspotService();
  final SyncService _sync = SyncService();

  bool _isServerOnline = false;
  bool _isHotspotActive = false;
  String? _deviceIp;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final online = await _network.testConnection();
    final hActive = await _hotspot.isHotspotEnabled();
    final ip = await _hotspot.getIpAddress();

    if (mounted) {
      setState(() {
        _isServerOnline = online;
        _isHotspotActive = hActive;
        _deviceIp = ip;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الشبكة والمزامنة'),
        actions: [
          IconButton(onPressed: _checkStatus, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== حالة الاتصال بالسيرفر =====
            _buildStatusCard(
              title: 'حالة السيرفر (PHP/MySQL)',
              subtitle:
                  _isServerOnline ? 'متصل ومستقر' : 'غير قادر على الاتصال',
              icon: Icons.dns,
              color: _isServerOnline ? Colors.green : Colors.red,
              trailing: Switch(
                value: _isServerOnline,
                onChanged: (_) => _checkStatus(),
              ),
            ),

            const SizedBox(height: 16),

            // ===== نقطة الاتصال =====
            _buildStatusCard(
              title: 'نقطة الاتصال المحلية (Hotspot)',
              subtitle:
                  _isHotspotActive
                      ? 'نشطة - IP: ${_deviceIp ?? "..."}'
                      : 'متوقفة - استخدمها للتواصل بدون إنترنت',
              icon: Icons.wifi_tethering,
              color: _isHotspotActive ? Colors.blue : Colors.grey,
              trailing: Switch(
                value: _isHotspotActive,
                onChanged: (val) async {
                  if (val) {
                    await _hotspot.enableHotspot();
                  } else {
                    await _hotspot.disableHotspot();
                  }
                  _checkStatus();
                },
              ),
            ),

            const SizedBox(height: 24),

            // ===== أزرار العمليات =====
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _sync.isSyncing
                            ? null
                            : () async {
                              final success = await _sync.syncAll();
                              if (mounted) {
                                if (success) {
                                  UIUtils.showSuccessSnackBar(
                                    context,
                                    'تمت المزامنة بنجاح',
                                  );
                                } else {
                                  UIUtils.showErrorSnackBar(
                                    context,
                                    'فشل المزامنة - تأكد من اتصال السيرفر',
                                  );
                                }
                              }
                            },
                    icon:
                        _sync.isSyncing
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.sync),
                    label: const Text('مزامنة البيانات الآن'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعليمات المزامنة:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. تأكد من اتصال هاتفك بنفس شبكة السيرفر (Wi-Fi).'),
                    Text(
                      '2. إذا كنت المعلم، قم بتشغيل Hotspot ليتصل الطلاب بك.',
                    ),
                    Text(
                      '3. يتم حفظ البيانات محلياً وتلقائياً عند وجود اتصال.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget trailing,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}
