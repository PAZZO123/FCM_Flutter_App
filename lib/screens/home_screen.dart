import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FCMService _fcmService = FCMService();

  String? _deviceToken;
  bool _tokenLoading = true;
  bool _permissionGranted = false;

  // List of received notifications shown in the UI
  final List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Initialize FCM (permissions, handlers, local notifications)
    await _fcmService.initialize();

    // Listen for new messages and show a popup + add to list
    _fcmService.messageNotifier.addListener(_onNewMessage);

    // Fetch & display the device token
    final token = await _fcmService.getToken();
    if (mounted) {
      setState(() {
        _deviceToken = token;
        _tokenLoading = false;
        _permissionGranted = token != null;
      });
    }
  }

  void _onNewMessage() {
    final message = _fcmService.messageNotifier.value;
    if (message == null) return;

    final title = message.notification?.title ?? '(no title)';
    final body = message.notification?.body ?? '(no body)';
    final time = TimeOfDay.now().format(context);

    setState(() {
      _notifications.insert(0, {
        'title': title,
        'body': body,
        'time': time,
      });
    });

    // Show popup dialog
    _showNotificationDialog(title, body);
  }

  void _showNotificationDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF1A73E8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(body, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _copyToken() {
    if (_deviceToken == null) return;
    Clipboard.setData(ClipboardData(text: _deviceToken!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _fcmService.messageNotifier.removeListener(_onNewMessage);
    super.dispose();
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        title: const Text(
          'FCM Push Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildTokenCard(),
            const SizedBox(height: 16),
            _buildNotificationsSection(),
          ],
        ),
      ),
    );
  }

  // ─── Status Card ─────────────────────────────────────────────────────────

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _permissionGranted
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _permissionGranted
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _permissionGranted ? Colors.green : Colors.orange,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _permissionGranted
                        ? 'Notifications Enabled'
                        : 'Notifications Disabled',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _permissionGranted
                        ? 'Your device is ready to receive push notifications.'
                        : 'Please enable notifications in device settings.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Token Card ──────────────────────────────────────────────────────────

  Widget _buildTokenCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.key, color: Color(0xFF1A73E8), size: 20),
                SizedBox(width: 8),
                Text(
                  'Device FCM Token',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_tokenLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_deviceToken == null)
              const Text(
                'Unable to retrieve token. Check Firebase setup.',
                style: TextStyle(color: Colors.red),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  _deviceToken!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _copyToken,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy Token'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Use this token in Firebase Console → Cloud Messaging to send a test notification.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Notifications List ──────────────────────────────────────────────────

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Received Notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (_notifications.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _notifications.clear()),
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_notifications.isEmpty)
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'No notifications yet.\nSend one from Firebase Console!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_notifications.map((n) => _buildNotificationItem(n))),
      ],
    );
  }

  Widget _buildNotificationItem(Map<String, String> n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F0FE),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications, color: Color(0xFF1A73E8)),
        ),
        title: Text(
          n['title']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n['body']!),
            const SizedBox(height: 2),
            Text(
              n['time']!,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
