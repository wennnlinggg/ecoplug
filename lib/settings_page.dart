import 'package:flutter/material.dart';
import 'api_service.dart';
import 'notification_settings_page.dart';
import 'security_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _priceController = TextEditingController();
  bool _loadingPrice = true;
  bool _savingPrice = false;
  num _currentPrice = 5;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadPrice() async {
    setState(() => _loadingPrice = true);
    try {
      final data = await ApiService.getSettings();
      _currentPrice = data["pricePerKwh"] ?? 5;
      _priceController.text = _currentPrice.toString();
    } catch (_) {
      _currentPrice = 5;
      _priceController.text = "5";
    }
    if (mounted) setState(() => _loadingPrice = false);
  }

  Future<void> _savePrice() async {
    final value = num.tryParse(_priceController.text.trim());

    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid price.")),
      );
      return;
    }

    setState(() => _savingPrice = true);
    try {
      final data = await ApiService.updatePrice(value);
      _currentPrice = data["pricePerKwh"] ?? value;
      _priceController.text = _currentPrice.toString();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Price updated!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Update failed: $e")));
      }
    }
    if (mounted) setState(() => _savingPrice = false);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [Colors.green.shade100, Colors.green.shade50.withAlpha(153)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // -------- Energy & Cost (REAL BACKEND) --------
                  Text(
                    'Energy & Cost',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Electricity price (NTD/kWh)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _loadingPrice ? null : _loadPrice,
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                          Text("Current: $_currentPrice"),
                          const SizedBox(height: 10),
                          if (_loadingPrice)
                            const Center(child: CircularProgressIndicator())
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _priceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: "New price",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _savingPrice ? null : _savePrice,
                                  child: _savingPrice
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text("Save"),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // -------- General (your friend's UI) --------
                  Text(
                    'General',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Notification settings'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationSettingsPage())),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Security settings'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecuritySettingsPage())),
                           
                          ),
                        
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Dark mode of plugins'),
                          trailing: Switch(value: false, onChanged: (_) {}),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // -------- Language & Region --------
                  Text(
                    'Language & region',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    child: Column(
                      children: const [
                        ListTile(
                          title: Text('Region'),
                          trailing: Icon(Icons.chevron_right),
                        ),
                        Divider(height: 1),
                        ListTile(
                          title: Text('Language'),
                          trailing: Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                                    const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // navigate to login and clear stack
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      },
                      child: const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
