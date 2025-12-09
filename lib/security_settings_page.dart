import 'package:flutter/material.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _twoFactor = true;
  bool _appLock = false;

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFEAF6E9);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        title: const Text('Security Settings', style: TextStyle(color: Colors.black)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
      ),
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text('Account Security', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Two-Factor Authemication (2FA)', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Manage your verification methods', style: TextStyle(color: Colors.black54)),
                      trailing: Switch(value: _twoFactor, activeColor: Colors.green[700], onChanged: (v) => setState(() => _twoFactor = v)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(title: const Text('Change Password'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
                    const Divider(height: 1),
                    ListTile(title: const Text('Recent Login Activity'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text('Device Management', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(title: const Text('Manage Authorized Devices'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.lock_outline, color: Colors.black54),
                      ),
                      title: const Text('App Lock', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Switch(value: _appLock, activeColor: Colors.green[700], onChanged: (v) => setState(() => _appLock = v)),
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
