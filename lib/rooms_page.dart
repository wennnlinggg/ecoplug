import 'package:flutter/material.dart';
import 'api_service.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final _roomNameController = TextEditingController();
  bool _loading = true;
  List<dynamic> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() => _loading = true);
    try {
      _rooms = await ApiService.getRooms();
    } catch (e) {
      _rooms = [];
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load rooms: $e")));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addRoom() async {
    final name = _roomNameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a room name")));
      return;
    }

    try {
      await ApiService.addRoom(name);
      _roomNameController.clear();
      await _loadRooms(); // ✅ refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add room: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
        actions: [
          IconButton(onPressed: _loadRooms, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ✅ input row like your screenshot
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roomNameController,
                    decoration: const InputDecoration(
                      labelText: "Room name",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addRoom(), // ✅ enter to add
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _addRoom,
                    child: const Text("Add"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _rooms.isEmpty
                  ? const Center(
                      child: Text(
                        "No rooms yet",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _rooms.length,
                      itemBuilder: (_, i) {
                        final r = _rooms[i];
                        return ListTile(
                          leading: const Icon(Icons.meeting_room_outlined),
                          title: Text(r["name"]?.toString() ?? "Unnamed"),
                          subtitle: Text("id: ${r["id"] ?? "-"}"),
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
