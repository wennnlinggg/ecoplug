import 'package:flutter/material.dart';
import 'api_service.dart';
import 'rooms_page.dart';
import 'appliances_page.dart';

class EnergyDashboardPage extends StatefulWidget {
  const EnergyDashboardPage({super.key});

  @override
  State<EnergyDashboardPage> createState() => _EnergyDashboardPageState();
}

class _EnergyDashboardPageState extends State<EnergyDashboardPage> {
  bool _loading = true;
  List<dynamic> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _loading = true);
    try {
      _devices = await ApiService.getDevices();
    } catch (_) {
      _devices = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _on(String id) async {
    await ApiService.deviceOn(id);
    await _loadDevices();
  }

  Future<void> _off(String id) async {
    await ApiService.deviceOff(id);
    await _loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Energy"),
        actions: [
          IconButton(onPressed: _loadDevices, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.meeting_room_outlined),
                          label: const Text("Rooms"),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RoomsPage(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.electrical_services_outlined),
                          label: const Text("Appliances"),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AppliancesPage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Tuya Devices",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (_, i) {
                        final d = _devices[i];
                        final id = d["id"]?.toString() ?? "";

                        return Card(
                          child: ListTile(
                            title: Text(
                              d["name"]?.toString() ?? "Unnamed device",
                            ),
                            subtitle: Text("id: $id"),
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                OutlinedButton(
                                  onPressed: id.isEmpty ? null : () => _on(id),
                                  child: const Text("On"),
                                ),
                                OutlinedButton(
                                  onPressed: id.isEmpty ? null : () => _off(id),
                                  child: const Text("Off"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
