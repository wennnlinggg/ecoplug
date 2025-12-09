import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _allEnabled = true;
  bool _generalNotifications = false;
  bool _energyTips = false;
  bool _doNotDisturb = false;
  bool _vibration = false;

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFEAF6E9); // pale green background similar to screenshot

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Enable All Notifications',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                      Switch(
                        value: _allEnabled,
                        activeColor: Colors.green[700],
                        onChanged: (v) => setState(() => _allEnabled = v),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text('General', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Notification Types', style: TextStyle(color: Colors.black45)),
              ),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('General Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Switch(
                        value: _generalNotifications,
                        onChanged: (v) => setState(() => _generalNotifications = v),
                        activeColor: Colors.green[700],
                      ),
                    ),
                    const Divider(height: 0.5),
                    ListTile(
                      title: const Text('Energy Saving Tips', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text(
                        'Recommended to keep on Promotional.\nRecommended',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                      trailing: Switch(
                        value: _energyTips,
                        onChanged: (v) => setState(() => _energyTips = v),
                        activeColor: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text('Common Settings', style: TextStyle(fontWeight: FontWeight.w700)),
              ),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.nights_stay, color: Colors.green),
                      ),
                      title: const Text('Do Not Disturb Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Switch(
                        value: _doNotDisturb,
                        onChanged: (v) => setState(() => _doNotDisturb = v),
                        activeColor: Colors.green[700],
                      ),
                    ),
                    const Divider(height: 0.5),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.vibration, color: Colors.black54),
                      ),
                      title: const Text('Notification Vibration', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Switch(
                        value: _vibration,
                        onChanged: (v) => setState(() => _vibration = v),
                        activeColor: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
