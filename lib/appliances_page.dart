import 'package:flutter/material.dart';
import 'api_service.dart';
import 'appliance_dialogs.dart';

class AppliancesPage extends StatefulWidget {
  const AppliancesPage({super.key});

  @override
  State<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage> {
  bool _loading = true;
  List<dynamic> _rooms = [];
  List<dynamic> _appliances = [];
  String? _selectedRoomId;

  final _name = TextEditingController();
  final _deviceId = TextEditingController();
  final _wattage = TextEditingController();

  // ✅ for add room dialog
  final _roomName = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  @override
  void dispose() {
    _name.dispose();
    _deviceId.dispose();
    _wattage.dispose();
    _roomName.dispose();
    super.dispose();
  }

  Future<void> _initLoad() async {
    setState(() => _loading = true);
    try {
      _rooms = await ApiService.getRooms();
      _appliances = await ApiService.getAppliances(roomId: _selectedRoomId);
    } catch (_) {
      _rooms = [];
      _appliances = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _filterByRoom(String? roomId) async {
    _selectedRoomId = roomId;
    setState(() => _loading = true);
    try {
      _appliances = await ApiService.getAppliances(roomId: roomId);
    } catch (_) {
      _appliances = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  // ✅ ADD ROOM FLOW
  Future<void> _openAddRoomDialog() async {
    _roomName.clear();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Room"),
        content: TextField(
          controller: _roomName,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g., Living Room",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _roomName.text.trim();
              if (name.isEmpty) return;

              try {
                final newRoom = await ApiService.addRoom(name);
                if (!mounted) return;

                // refresh rooms
                _rooms = await ApiService.getRooms();

                // auto select new room (so your add appliance works immediately)
                final newId = newRoom["id"]?.toString();
                if (newId != null) {
                  _selectedRoomId = newId;
                  _appliances = await ApiService.getAppliances(roomId: newId);
                }

                setState(() {});
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add room: $e")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addAppliance() async {
    final name = _name.text.trim();
    final deviceId = _deviceId.text.trim();
    final watt = num.tryParse(_wattage.text.trim()) ?? 0;

    if (name.isEmpty || deviceId.isEmpty || _selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill name, deviceId, and select a room."),
        ),
      );
      return;
    }

    try {
      await ApiService.addAppliance({
        "name": name,
        "deviceId": deviceId,
        "roomId": _selectedRoomId,
        "wattage": watt,
      });

      _name.clear();
      _deviceId.clear();
      _wattage.clear();

      await _filterByRoom(_selectedRoomId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add appliance: $e")));
    }
  }

  // ✅ REPLACED with your nice UI dialogs
  Future<void> _showStats(String id) async {
    try {
      final data = await ApiService.getApplianceStats(id);
      if (!mounted) return;
      await showStatsDialog(context, data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Stats error: $e")));
    }
  }

  Future<void> _showCarbon(String id) async {
    try {
      final data = await ApiService.getApplianceCarbon(id);
      if (!mounted) return;
      await showCarbonDialog(context, data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Carbon error: $e")));
    }
  }

  Future<void> _showHistory(String id) async {
    try {
      final data = await ApiService.getApplianceHistory(id);
      if (!mounted) return;
      await showHistoryDialog(context, data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("History error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appliances"),
        actions: [
          IconButton(onPressed: _initLoad, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // ✅ Room filter + Add Room button
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRoomId,
                          decoration: const InputDecoration(
                            labelText: "Select Room",
                            border: OutlineInputBorder(),
                          ),
                          items: _rooms.map((r) {
                            return DropdownMenuItem(
                              value: r["id"]?.toString(),
                              child: Text(r["name"]?.toString() ?? "Unnamed"),
                            );
                          }).toList(),
                          onChanged: (v) => _filterByRoom(v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _openAddRoomDialog,
                          icon: const Icon(Icons.add),
                          label: const Text("Room"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Add appliance form
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: "Appliance name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _deviceId,
                    decoration: const InputDecoration(
                      labelText: "Tuya deviceId",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _wattage,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Wattage (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addAppliance,
                      child: const Text("Add Appliance"),
                    ),
                  ),
                  const Divider(),

                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _appliances.length,
                      itemBuilder: (_, i) {
                        final a = _appliances[i];
                        final id = a["id"]?.toString() ?? "";

                        return Card(
                          child: ListTile(
                            title: Text(a["name"]?.toString() ?? "Unnamed"),
                            subtitle: Text("deviceId: ${a["deviceId"] ?? "-"}"),
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                IconButton(
                                  tooltip: "Stats",
                                  onPressed: id.isEmpty
                                      ? null
                                      : () => _showStats(id),
                                  icon: const Icon(Icons.query_stats),
                                ),
                                IconButton(
                                  tooltip: "Carbon",
                                  onPressed: id.isEmpty
                                      ? null
                                      : () => _showCarbon(id),
                                  icon: const Icon(Icons.eco),
                                ),
                                IconButton(
                                  tooltip: "History",
                                  onPressed: id.isEmpty
                                      ? null
                                      : () => _showHistory(id),
                                  icon: const Icon(Icons.history),
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
