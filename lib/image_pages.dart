import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'notifications_page.dart';
import 'recommendation_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [Colors.green.shade100, Colors.green.shade50.withAlpha(153)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    Widget imageCard(String title, Color color, {String? assetName, VoidCallback? onTap}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // image area
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: assetName != null
                      ? Image.asset(
                          'assets/images/$assetName',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: color),
                        )
                      : Container(color: color),
                ),
              ),

              // title bar under the image
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                child: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text('Eco Plug', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28, color: Colors.green[900])),
                const SizedBox(height: 12),
                imageCard('Net Zero', Colors.pink.shade300, assetName: 'a.png', onTap: () => Navigator.of(context).pushNamed('/netzero')),
                imageCard('Eco Plug', Colors.green.shade300, assetName: 'b.png', onTap: () => Navigator.of(context).pushNamed('/eco')),
                imageCard('Tips & Tricks', Colors.blueGrey.shade300, assetName: 'd.png', onTap: () => Navigator.of(context).pushNamed('/tips')),
                imageCard('Learn How You Can Help', Colors.teal.shade300, assetName: 'c.png', onTap: () => Navigator.of(context).pushNamed('/learn')),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EnergyPage extends StatefulWidget {
  const EnergyPage({Key? key}) : super(key: key);

  @override
  State<EnergyPage> createState() => _EnergyPageState();
}

class _EnergyPageState extends State<EnergyPage> {
  Map<String, Map<String, String>> _roomsMap = {};
  List<String> _roomOrder = [];
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('energy_rooms_map');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decodedRaw = json.decode(jsonStr);
        // support legacy format (direct map) and new format {'map': {...}, 'order': [...]}
        if (decodedRaw is Map && decodedRaw.containsKey('map')) {
          final decoded = Map<String, dynamic>.from(decodedRaw['map'] as Map);
          final map = decoded.map((k, v) {
            if (v is Map) {
              return MapEntry(k, Map<String, String>.from(v.map((key, val) => MapEntry(key.toString(), val?.toString() ?? ''))));
            }
            return MapEntry(k, <String, String>{});
          });
          final orderRaw = decodedRaw['order'];
          final orderList = orderRaw is List ? List<String>.from(orderRaw.map((e) => e.toString())) : map.keys.toList();
          setState(() {
            _roomsMap = map;
            _roomOrder = orderList;
          });
        } else if (decodedRaw is Map) {
          final decoded = Map<String, dynamic>.from(decodedRaw);
          final map = decoded.map((k, v) {
            if (v is Map) {
              return MapEntry(k, Map<String, String>.from(v.map((key, val) => MapEntry(key.toString(), val?.toString() ?? ''))));
            }
            return MapEntry(k, <String, String>{});
          });
          setState(() {
            _roomsMap = map;
            _roomOrder = map.keys.toList();
          });
        }
      }
    } catch (_) {
      // ignore errors
    }
  }

  Future<void> _saveRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // store both map and explicit order
      final payload = {'map': _roomsMap, 'order': _roomOrder};
      final jsonStr = json.encode(payload);
      await prefs.setString('energy_rooms_map', jsonStr);
    } catch (_) {}
  }

  void _onAddRoom() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(MaterialPageRoute(builder: (_) => const AddNewRoomPage()));
    if (result != null) {
      final room = (result['room'] as String?)?.trim();
      final thing = (result['thing'] as String?)?.trim() ?? '';
      final image = (result['image'] as String?) ?? '';
      if (room != null && room.isNotEmpty) {
        // update map and persist, maintain order
        setState(() {
          _roomsMap[room] = {'thing': thing, 'image': image};
          if (!_roomOrder.contains(room)) _roomOrder.add(room);
        });
        await _saveRooms();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            const SizedBox(height: 8),
            // Top row: notification (left), title (center), add button (right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  // notification
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage())),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Eco Plug', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.green)),
                    ),
                  ),
                  // small add/edit menu
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'add') {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddDevicePage()));
                      } else if (v == 'edit') {
                        // toggle edit mode on/off
                        setState(() => _editing = !_editing);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'add', child: Text('Add Device')),
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                    ],
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // main content: either placeholder when empty (like Schedule) or grid of rooms
            Expanded(
              child: _roomsMap.isEmpty ? _emptyPlaceholder() : _roomsGrid(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onAddRoom,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _editing
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          setState(() => _editing = false);
                          await _saveRooms();
                        },
                        child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Done')),
                      ),
                    ),
                  ]),
                ),
              )
            : null,
      ),
    );
  }

  Widget _emptyPlaceholder() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
              child: const Center(child: Icon(Icons.bolt, size: 64, color: Colors.black26)),
            ),
            const SizedBox(height: 16),
            const Text('Nothing here yet', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            const Text('Tap + to add a new room', style: TextStyle(color: Colors.black45, fontSize: 12)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _roomsGrid() {
    // when editing show a reorderable list
    if (_editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ReorderableListView(
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex -= 1;
            setState(() {
              final item = _roomOrder.removeAt(oldIndex);
              _roomOrder.insert(newIndex, item);
            });
            await _saveRooms();
          },
          children: List.generate(_roomOrder.length, (i) {
            final r = _roomOrder[i];
            final entry = _roomsMap[r] ?? {};
            return ListTile(
              key: ValueKey('room_$r'),
              leading: const Icon(Icons.drag_handle),
              title: Text(r),
              subtitle: Text(entry['thing'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  setState(() {
                    _roomsMap.remove(r);
                    _roomOrder.remove(r);
                  });
                  await _saveRooms();
                },
              ),
            );
          }),
        ),
      );
    }

    // normal grid view when not editing
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 18,
        childAspectRatio: 0.8,
        children: _roomsMap.keys.map((r) {
          final entry = _roomsMap[r];
          Widget avatarChild = const Icon(Icons.kitchen, color: Colors.green, size: 28);

          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RoomPage(name: r))),
            child: Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 26, backgroundColor: Colors.grey[50], child: avatarChild),
                    const SizedBox(height: 10),
                    Text(r, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 100,
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 26, backgroundColor: Colors.grey[50], child: Icon(icon, color: Colors.green, size: 28)),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomPage extends StatefulWidget {
  const RoomPage({required this.name, Key? key}) : super(key: key);
  final String name;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<Map<String, String>> devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('energy_rooms_map');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decodedRaw = json.decode(jsonStr);

        Map<String, dynamic>? roomsMap;

        // Support both formats: either direct map {room: {thing,image}} or wrapper {'map': {...}, 'order': [...]}
        if (decodedRaw is Map && decodedRaw.containsKey('map')) {
          final mapPart = decodedRaw['map'];
          if (mapPart is Map) roomsMap = Map<String, dynamic>.from(mapPart);
        } else if (decodedRaw is Map<String, dynamic>) {
          roomsMap = Map<String, dynamic>.from(decodedRaw);
        }

        if (roomsMap != null && roomsMap.containsKey(widget.name)) {
          final entry = roomsMap[widget.name];
          if (entry is Map) {
            final thingName = (entry['thing'] as String?) ?? '';
            final imagePath = (entry['image'] as String?) ?? '';
            if (thingName.isNotEmpty) {
              setState(() {
                final slug = thingName.toLowerCase().replaceAll(' ', '_');
                final asset = 'assets/images/$slug.png';
                final image = imagePath.isNotEmpty ? imagePath : asset;
                devices = [
                  {'name': thingName, 'asset': asset, 'image': image},
                ];
              });
              return;
            }
          }
        }
      }
    } catch (_) {}

    // fallback sample devices
    setState(() {
      devices = [
        {'name': 'Blender', 'asset': 'assets/images/blender.png', 'image': 'assets/images/blender.png'},
        {'name': 'Toaster', 'asset': 'assets/images/toaster.png', 'image': 'assets/images/toaster.png'},
        {'name': 'Oven', 'asset': 'assets/images/oven.png', 'image': 'assets/images/oven.png'},
        {'name': 'Dishwasher', 'asset': 'assets/images/dishwasher.png', 'image': 'assets/images/dishwasher.png'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF4),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: Text(widget.name),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 18,
          childAspectRatio: 0.75,
          children: devices.map((d) {
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DeviceDetailPage(name: d['name']!, asset: d['asset'], imageUrl: d['image']!))),
              child: _DeviceCard(name: d['name']!, asset: d['asset'], imageUrl: d['image']!),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFBFF2C9),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.name, required this.imageUrl, this.asset, Key? key}) : super(key: key);
  final String name;
  final String imageUrl;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 88,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ClipOval(
                    child: _buildImageWidget(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildImageWidget() {
    try {
      if (imageUrl.isNotEmpty) {
        // network image
        if (imageUrl.startsWith('http')) {
          return Image.network(
            imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _networkFallback(),
          );
        }

        // handle file:// URIs and local file paths
        var path = imageUrl;
        if (path.startsWith('file://')) path = path.replaceFirst('file://', '');
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(file, width: 64, height: 64, fit: BoxFit.cover);
        }
      }

      // asset fallback
      if (asset != null && asset!.isNotEmpty) {
        return Image.asset(
          asset!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _networkFallback(),
        );
      }
    } catch (_) {
      // ignore and fall through to fallback
    }
    return _networkFallback();
  }

  Widget _networkFallback() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey[200],
      child: const Icon(Icons.kitchen, color: Colors.grey),
    );
  }
}

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({required this.name, this.asset, required this.imageUrl, Key? key}) : super(key: key);
  final String name;
  final String? asset;
  final String imageUrl;

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  bool _isOn = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPowerState();
  }

  void _togglePower() {
    setState(() {
      _isOn = !_isOn;
    });
    _savePowerState();
  }

  String _prefsKey() => 'device_power_${widget.name.replaceAll(' ', '_').toLowerCase()}';

  Future<void> _loadSavedPowerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool(_prefsKey());
      if (val != null) {
        setState(() => _isOn = val);
      }
    } catch (_) {
      // ignore errors; default _isOn stays false
    }
  }

  Future<void> _savePowerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey(), _isOn);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    // Use fixed smartplug asset for device detail image per request
    try {
      imageWidget = Image.asset(
        'assets/images/smartplug.png',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _detailImageFallback(widget.imageUrl),
      );
    } catch (_) {
      imageWidget = _detailImageFallback(widget.imageUrl);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF4),
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('Smart plug device', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _togglePower,
                              icon: const Icon(Icons.power_settings_new, color: Colors.white),
                              label: Text(_isOn ? 'Turn Off' : 'Turn On'),
                              style: ElevatedButton.styleFrom(backgroundColor: _isOn ? Colors.red : Colors.green),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(onPressed: () {}, child: const Text('Share')),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Power Statistics card (tappable)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DevicePowerStatisticsPage(deviceName: widget.name))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Power Statistics', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  _StatColumn(value: '0.2', unit: 'kWh', label: 'Electricity today'),
                                  _StatColumn(value: '12.0', unit: 'w', label: 'Current power'),
                                  _StatColumn(value: '2.0', unit: 'hours', label: 'Runtime today'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Power Source card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                  child: Row(
                    children: [
                      // left: small device icon + label
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
                            child: Center(child: Image.asset('assets/images/smartplug.png', width: 36, height: 36, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.power))),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Power Source', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('Switch', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      // big power button on right
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: _isOn ? Colors.red : Colors.green, shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: _togglePower,
                          icon: const Icon(Icons.power_settings_new, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // List options
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Schedule'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SchedulePage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.flag),
                      title: const Text('Goals'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GoalsPage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.eco),
                      title: const Text('Carbon Emission'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CarbonEmissionPage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.recommend),
                      title: const Text('Recommendations'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecommendationPage())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailImageFallback(String imageUrl) {
    // If imageUrl looks like a network URL, use Image.network, otherwise show a placeholder icon
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(width: 120, height: 120, color: Colors.grey[200], child: const Icon(Icons.kitchen, color: Colors.grey)),
      );
    }

    return Container(width: 120, height: 120, color: Colors.grey[200], child: const Icon(Icons.kitchen, color: Colors.grey));
  }

  Widget _smallImageWidget(String? imageUrl) {
    final url = imageUrl ?? '';
    try {
      if (url.startsWith('http')) {
        return Image.network(url, width: 36, height: 36, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.power));
      }
      final f = File(url);
      if (f.existsSync()) {
        return Image.file(f, width: 36, height: 36, fit: BoxFit.contain);
      }
      return Image.asset(url, width: 36, height: 36, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.power));
    } catch (_) {
      return const Icon(Icons.power);
    }
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.unit, required this.label, Key? key}) : super(key: key);
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Text(unit, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

class DevicePowerStatisticsPage extends StatefulWidget {
  const DevicePowerStatisticsPage({required this.deviceName, Key? key}) : super(key: key);
  final String deviceName;

  @override
  State<DevicePowerStatisticsPage> createState() => _DevicePowerStatisticsPageState();
}

class _DevicePowerStatisticsPageState extends State<DevicePowerStatisticsPage> {
  int _selectedRange = 0; // 0: Week, 1: Month, 2: Year

  Widget _buildTopStat(String value, String unit, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Text(unit, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Statistics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6FBF4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, MediaQuery.of(context).viewInsets.bottom + 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.deviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // top two rows of stats (3 + 3)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildTopStat('0.2', 'kWh', 'Electricity today'),
                            _buildTopStat('0.4', 'kWh', 'Electricity yesterday'),
                            _buildTopStat('5.9', 'kWh', 'Electricity this month'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTopStat('12.0', 'w', 'Current power'),
                            _buildTopStat('2.0', 'hours', 'Runtime today'),
                            _buildTopStat('15.0', 'hours', 'Runtime this month'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                // segmented control
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final labels = ['Week', 'Month', 'Year'];
                      final selected = _selectedRange == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRange = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: selected ? Colors.grey[200] : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(labels[i], style: TextStyle(color: selected ? Colors.black : Colors.black54, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 8),
                // date range selector
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text('04/25-05/01', style: TextStyle(color: Colors.black54)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ],
                ),

                const SizedBox(height: 12),
                // chart card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('0.9 kWh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text('Total electricity', style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // chart placeholder with simple simulated line
                        SizedBox(
                          height: 180,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                  child: CustomPaint(
                                    painter: _SparklinePainter(),
                                    child: Container(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('04/25', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            Text('05/01', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // sample points to simulate a rising line
    final points = <Offset>[
      Offset(0, size.height * 0.9),
      Offset(size.width * 0.15, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.45, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width * 0.9, size.height * 0.15),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // fill gradient under line
    final fillPaint = Paint()..shader = LinearGradient(colors: [Colors.blue.withOpacity(0.15), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LargeStat extends StatelessWidget {
  const _LargeStat({required this.value, required this.unit, required this.label, Key? key}) : super(key: key);
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text(unit, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Map<String, dynamic>> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('alarms') ?? [];
      setState(() {
        _alarms = list.map((s) {
          try {
            return Map<String, dynamic>.from(jsonDecode(s) as Map);
          } catch (_) {
            return <String, dynamic>{};
          }
        }).where((m) => m.isNotEmpty).toList();
      });
    } catch (_) {}
  }

  Future<void> _toggleEnabled(int idx, bool v) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('alarms') ?? [];
    final map = Map<String, dynamic>.from(_alarms[idx]);
    map['enabled'] = v;
    list[idx] = jsonEncode(map);
    await prefs.setStringList('alarms', list);
    await _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [IconButton(onPressed: () async { await Navigator.of(context).pushNamed('/setAlarm'); await _loadAlarms(); }, icon: const Icon(Icons.add))],
      ),
      backgroundColor: Colors.white,
      body: _alarms.isEmpty
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                      child: const Center(child: Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.black26)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Nothing here yet', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _alarms.length,
              separatorBuilder: (_, __) => const Divider(height: 8),
              itemBuilder: (ctx, i) {
                final a = _alarms[i];
                final sh = a['startHour'] ?? 0;
                final sm = a['startMinute'] ?? 0;
                final eh = a['endHour'] ?? 0;
                final em = a['endMinute'] ?? 0;
                final enabled = a['enabled'] ?? true;
                final label = a['label'] ?? '';
                final fmt = (int h, int m) => '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}';
                return ListTile(
                  title: Text('${fmt(sh, sm)} - ${fmt(eh, em)}'),
                  subtitle: Text(label.toString()),
                  trailing: Switch(value: enabled, onChanged: (v) => _toggleEnabled(i, v)),
                  onTap: () async {
                    await Navigator.of(context).pushNamed('/setAlarm', arguments: {'alarm': a, 'index': i});
                    await _loadAlarms();
                  },
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  // internal canonical values stored in kWh
  double _todayKwh = 9.0;
  double _goalKwh = 12.0;
  String _displayUnit = 'kWh'; // 'kWh' or 'W'
  bool _loading = true;
  double _runtimeHours = 8.0;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // goal value stored in Settings is saved as the displayed number in its unit
      final storedGoal = prefs.getDouble('goal_electricity_value');
      final storedUnit = prefs.getString('goal_electricity_unit') ?? 'W';
      // today's electricity may be stored as kWh under 'today_electricity_kwh'
      final storedToday = prefs.getDouble('today_electricity_kwh');
      final storedRuntime = prefs.getDouble('goal_runtime_value');
      final storedRuntimeUnit = prefs.getString('goal_runtime_unit') ?? 'Hours';

      setState(() {
        _displayUnit = storedUnit == 'W' ? 'W' : 'kWh';
        if (storedGoal != null) {
          // normalize to kWh internally
          _goalKwh = (_displayUnit == 'W') ? (storedGoal / 1000.0) : storedGoal;
        }
        if (storedToday != null) {
          _todayKwh = storedToday;
        }
        if (storedRuntime != null) {
          // runtime stored as hours in Settings UI
          _runtimeHours = storedRuntime;
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  double _toDisplay(double kwh) => (_displayUnit == 'W') ? kwh * 1000.0 : kwh;

  String _unitLabel() => _displayUnit;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final displayToday = _toDisplay(_todayKwh);
    final displayGoal = _toDisplay(_goalKwh);
    final double pct = (_goalKwh <= 0) ? 0.0 : (_todayKwh / _goalKwh).clamp(0.0, 1.0);
    final percentLabel = '${(pct * 100).round()}%';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text('Goals', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(onPressed: () async {
            // open settings; when returning reload prefs to reflect unit/value changes
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            await _loadPrefs();
          }, icon: const Icon(Icons.settings, color: Colors.black87)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // left stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(displayToday.toStringAsFixed(1), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            Text(_unitLabel(), style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Electricity\ntoday', style: TextStyle(color: Colors.black45, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // middle stat
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('6.0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            SizedBox(width: 6),
                            Text('hours', style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Time\ntoday', style: TextStyle(color: Colors.black45, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // right boxed percent
                  SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 28,
                          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(6)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: pct,
                                    child: Container(margin: const EdgeInsets.all(4.0), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4))),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Align(alignment: Alignment.centerRight, child: Text(percentLabel, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('${displayToday.toStringAsFixed(1)} / ${displayGoal.toStringAsFixed(1)} ${_unitLabel()}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // small chart with grid and bars
              Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                child: Stack(
                  children: [
                    Column(children: List.generate(4, (i) => Expanded(child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))))))),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(10, (i) {
                          final heights = [6, 8, 10, 30, 40, 28, 20, 48, 32, 12];
                          return Container(width: 8, height: heights[i].toDouble(), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)));
                        }),
                      ),
                    ),
                    Positioned(left: 4, right: 4, bottom: 0, child: Padding(padding: const EdgeInsets.only(top: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('6:00', style: TextStyle(fontSize: 10, color: Colors.black38)), Text('12:00', style: TextStyle(fontSize: 10, color: Colors.black38)), Text('18:00', style: TextStyle(fontSize: 10, color: Colors.black38)), Text('22:00', style: TextStyle(fontSize: 10, color: Colors.black38))]))),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text('Daily Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(displayGoal.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(_unitLabel(), style: const TextStyle(color: Colors.black54)), const SizedBox(height: 6), const Text('Electricity', style: TextStyle(color: Colors.black45, fontSize: 12))])),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_runtimeHours.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), const Text('hours', style: TextStyle(color: Colors.black54)), const SizedBox(height: 6), const Text('Runtime', style: TextStyle(color: Colors.black45, fontSize: 12))])),
                    ])
                  ]),
                ),
              ),

              const SizedBox(height: 12),
              Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]), child: ListTile(title: const Text('History'), trailing: const Icon(Icons.chevron_right), onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryPage())); })),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Add Device'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code))],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 6, height: 6, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                          children: [
                            const TextSpan(text: 'Searching for nearby devices. Make sure your device has entered '),
                            TextSpan(text: 'pairing mode', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                            Text('Turn on Wi‑Fi', style: TextStyle(fontWeight: FontWeight.w700)),
                            SizedBox(height: 6),
                            Text('Wi‑Fi is required to search for devices.', style: TextStyle(color: Colors.black54)),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                          child: const Icon(Icons.wifi, color: Colors.black26),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Radar illustration
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (var i = 5; i >= 1; i--)
                          Container(
                            width: 60.0 * i,
                            height: 60.0 * i,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.06 * i),
                              border: Border.all(color: Colors.blue.withOpacity(0.12)),
                            ),
                          ),
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Center(child: Text('Add Manually', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87))),
                const SizedBox(height: 18),

                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))]),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Icon(Icons.power_outlined, size: 28, color: Colors.green)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(child: Text('Socket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                        const Icon(Icons.chevron_right, color: Colors.black38),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddNewRoomPage extends StatefulWidget {
  const AddNewRoomPage({Key? key}) : super(key: key);

  @override
  State<AddNewRoomPage> createState() => _AddNewRoomPageState();
}

class _AddNewRoomPageState extends State<AddNewRoomPage> {
  final TextEditingController _ctrl = TextEditingController();
  bool _saving = false;
  final TextEditingController _thingCtrl = TextEditingController();
  String? _pickedImagePath;
  String? _selectedDevice;
  final List<String> _deviceOptions = ['Wifi Smart Plug', 'Air Conditioner', 'Wifi Bulb', 'Other'];
  String? _costs;
  final TextEditingController _customDeviceCtrl = TextEditingController();
  final TextEditingController _costsCtrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    _thingCtrl.dispose();
    _customDeviceCtrl.dispose();
    _costsCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter room name')));
      return;
    }
    setState(() => _saving = true);
    // return a map with room name, single thing, optional image path, device and costs
    final deviceValue = (_selectedDevice == 'Other') ? (_customDeviceCtrl.text.trim()) : (_selectedDevice ?? _deviceOptions.first);
    Navigator.of(context).pop({
      'room': text,
      'thing': _thingCtrl.text.trim(),
      'image': _pickedImagePath ?? '',
      'device': deviceValue,
      'costs': _costsCtrl.text.trim()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Room')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // top decorative icon
                const SizedBox(height: 8),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.eco, color: Colors.green, size: 54)),
                ),
                const SizedBox(height: 18),

                // Location card
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade100), color: Colors.white),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), TextField(controller: _ctrl, decoration: const InputDecoration.collapsed(hintText: 'e.g. Kitchen'))])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Things card with add photo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade100), color: Colors.white),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Things', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextField(controller: _thingCtrl, decoration: const InputDecoration.collapsed(hintText: 'e.g. Air Conditioner'))),
                      const SizedBox(width: 8),
                      TextButton.icon(onPressed: _pickImageBottomSheet, icon: const Icon(Icons.camera_alt_outlined, color: Colors.green), label: const Text('Add Photo', style: TextStyle(color: Colors.green)))
                    ]),
                    const SizedBox(height: 8),
                    if (_pickedImagePath == null || _pickedImagePath!.isEmpty)
                      const Text('', style: TextStyle(color: Colors.black54))
                    else
                      Row(children: [Image.file(File(_pickedImagePath!), width: 64, height: 64, fit: BoxFit.cover), const SizedBox(width: 8), Expanded(child: Text(_pickedImagePath!.split('/').last, overflow: TextOverflow.ellipsis)), IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _pickedImagePath = null))])
                  ]),
                ),
                const SizedBox(height: 12),

                // Device card (dropdown)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade100), color: Colors.white),
                  child: Row(children: [
                    const Icon(Icons.devices_outlined, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Device', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedDevice ?? _deviceOptions.first,
                        items: _deviceOptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (v) => setState(() {
                          _selectedDevice = v;
                          if (v != 'Other') _customDeviceCtrl.text = '';
                        }),
                      ),
                      if ((_selectedDevice ?? _deviceOptions.first) == 'Other')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextField(controller: _customDeviceCtrl, decoration: const InputDecoration(hintText: 'Enter device name', border: OutlineInputBorder())),
                        ),
                    ])),
                  ]),
                ),
                const SizedBox(height: 12),

                // Costs card (numeric-friendly)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade100), color: Colors.white),
                  child: Row(children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Costs', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      TextField(controller: _costsCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration.collapsed(hintText: 'e.g. 5'),),
                    ])),
                  ]),
                ),

                const SizedBox(height: 18),
                Row(children: [Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: _saving ? null : _onSave, child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Save Task'))))]),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(source: src, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
      if (xfile != null) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final filename = '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
          final newPath = '${appDir.path}/$filename';
          await File(xfile.path).copy(newPath);
          // crop & resize to a fixed square size to avoid very large images
          try {
            final f = File(newPath);
            await _cropAndResizeImage(f, 512);
          } catch (_) {}
          setState(() => _pickedImagePath = newPath);
        } catch (_) {
          // fallback: keep original path if copy fails
          setState(() => _pickedImagePath = xfile.path);
        }
      }
    } catch (_) {}
  }

  // Crop center and resize to `size` x `size` pixels. Overwrites the file.
  Future<void> _cropAndResizeImage(File file, int size) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return;

      // center-crop and resize to square using copyResizeCropSquare (compatible across versions)
      final resized = img.copyResizeCropSquare(image, size: size, interpolation: img.Interpolation.cubic);

      // encode to JPEG and overwrite
      final jpg = img.encodeJpg(resized, quality: 85);
      await file.writeAsBytes(jpg, flush: true);
    } catch (_) {
      // ignore errors and keep original file
    }
  }

  void _pickImageBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Take photo'), onTap: () { Navigator.of(ctx).pop(); _pickImage(ImageSource.camera); }),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from gallery'), onTap: () { Navigator.of(ctx).pop(); _pickImage(ImageSource.gallery); }),
          ],
        ),
      ),
    );
  }
}

// NotificationsPage is provided in `lib/notifications_page.dart`.

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _LayoutMock(title: 'Profile');
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _electricityGoal = 10.0; // editable between 0.1 - 20.0 per UI note
  String _electricityUnit = 'W'; // 'W' or 'kWh'

  double _runtimeGoal = 0.0;
  String _runtimeUnit = 'Hours';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _electricityGoal = prefs.getDouble('goal_electricity_value') ?? 10.0;
        _electricityUnit = prefs.getString('goal_electricity_unit') ?? 'W';
        _runtimeGoal = prefs.getDouble('goal_runtime_value') ?? 0.0;
        _runtimeUnit = prefs.getString('goal_runtime_unit') ?? 'Hours';
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('goal_electricity_value', _electricityGoal);
      await prefs.setString('goal_electricity_unit', _electricityUnit);
      await prefs.setDouble('goal_runtime_value', _runtimeGoal);
      await prefs.setString('goal_runtime_unit', _runtimeUnit);
    } catch (_) {}
  }

  // Basic conversion between units. Note: this is a simple multiplier (1 kWh <-> 1000 W)
  double _convertElectricity(double value, String from, String to) {
    if (from == to) return value;
    if (from == 'kWh' && to == 'W') return value * 1000.0;
    if (from == 'W' && to == 'kWh') return value / 1000.0;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await _savePrefs();
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6FBF4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Electricity Goal card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Electricity Goal', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(_electricityGoal.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _electricityUnit,
                            items: const [DropdownMenuItem(value: 'W', child: Text('W')), DropdownMenuItem(value: 'kWh', child: Text('kWh'))],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() {
                                // convert displayed value between units
                                _electricityGoal = _convertElectricity(_electricityGoal, _electricityUnit, v);
                                // clamp to allowed editable range 0.1..20.0
                                _electricityGoal = _electricityGoal.clamp(0.1, 20.0);
                                _electricityUnit = v;
                              });
                            },
                          ),
                        ],
                      ),
                      Slider(
                        min: 0.1,
                        max: 20.0,
                        value: _electricityGoal.clamp(0.1, 20.0),
                        onChanged: (v) => setState(() => _electricityGoal = v),
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Runtime Goal card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Runtime Goal', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(children: [Text(_runtimeGoal.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(width: 8), const Text('Hours')]),
                    Slider(min: 0.0, max: 24.0, value: _runtimeGoal.clamp(0.0, 24.0), onChanged: (v) => setState(() => _runtimeGoal = v), activeColor: Colors.green),
                    const SizedBox(height: 8),
                    const Text('Runtime Units', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(_runtimeUnit, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                ),

                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    'Note: Electricity goal is edited as a value between 0.1 and 20.0. When switching units the displayed number will convert (kWh ⇄ W). 0.0 is not allowed.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LayoutMock extends StatelessWidget {
  final String title;
  const _LayoutMock({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 320,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(4, (i) => _PlaceholderCard(index: i + 1)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Layout-only mockup — images not loaded', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  final int index;
  const _PlaceholderCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(child: Text('Screenshot $index', style: const TextStyle(fontSize: 12))),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

// Carbon Emission page — template matching the screenshot
class CarbonEmissionPage extends StatelessWidget {
  const CarbonEmissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text('Carbon Emission', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Today value (left) and illustration (right)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Today', style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text('Power (kWh)', style: TextStyle(fontSize: 13, color: Colors.black45)),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('100', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Text('kWh', style: TextStyle(fontSize: 18, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Illustration on the right (asset fallback)
                  SizedBox(
                    width: 160,
                    height: 110,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/solar_house.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[50],
                          child: const Center(child: Icon(Icons.house, size: 64, color: Colors.green)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // heading
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('If you reach this target:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
              ),

              const SizedBox(height: 8),

              // Stats grid
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                // remove spacing between the four stat boxes as requested
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                // make each tile taller to avoid vertical overflow on small screens
                childAspectRatio: 1.6,
                children: [
                  _statTile('72', 'kWh', 'Energy saved\nper month'),
                  _statTile('30.24', 'kg', 'CO2 saved\nper month'),
                  _statTile('1.5', 'trees', 'Equivalent to\nplanting'),
                  _statTile('3.29', 'hours', 'Equivalent of\ndriving'),
                ],
              ),

              const SizedBox(height: 16),

              Material(
                elevation: 0,
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DevicePowerStatisticsPage(deviceName: 'Home'))),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
                    child: const ListTile(
                      title: Text('Information'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(String value, String unit, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(unit, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPageState extends State<HistoryPage> {
  String _unit = 'kWh';
  bool _loading = true;
  // selected month (1..12). initialize to current month so the UI highlights correctly
  int _selectedMonth = DateTime.now().month;

  // sample entries now include a 'month' field (1..12) so we can filter by selected month.
  // In real usage, persist or load month along with the record when saving goals data.
  final List<Map<String, dynamic>> _entries = [
    {'kwh': 9.0, 'hours': 6.0, 'label': '3rd', 'month': 12},
    {'kwh': 9.0, 'hours': 6.0, 'label': '2nd', 'month': 12},
    {'kwh': 6.0, 'hours': 7.8, 'label': '25th', 'month': 11},
    {'kwh': 7.0, 'hours': 7.0, 'label': '23th', 'month': 10},
    {'kwh': 6.0, 'hours': 7.0, 'label': '21th', 'month': 9},
  ];

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('goal_electricity_unit') ?? 'W';
      setState(() {
        _unit = (stored == 'W') ? 'W' : 'kWh';
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  double _toDisplay(double kwh) => (_unit == 'W') ? kwh * 1000.0 : kwh;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // filter entries according to the selected month; if none found, show an empty list
    final filteredEntries = _entries.where((e) => (e['month'] ?? _selectedMonth) == _selectedMonth).toList();

    final maxKwh = (filteredEntries.isNotEmpty
        ? (filteredEntries.map((e) => e['kwh'] as double).fold<double>(0.0, (a, b) => a > b ? a : b))
        : 1.0)
      .clamp(1.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // months header (simple scrollable row) with selectable months
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (var idx = 0; idx < 12; idx++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMonth = idx + 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: (_selectedMonth == idx + 1) ? Colors.green.shade700 : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][idx],
                            style: TextStyle(
                              color: (_selectedMonth == idx + 1) ? Colors.white : Colors.black54,
                              fontWeight: (_selectedMonth == idx + 1) ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filteredEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final row = filteredEntries[i];
                  final kwh = row['kwh'] as double;
                  final hours = row['hours'] as double;
                  final label = row['label'] as String;
                  final displayKwh = _toDisplay(kwh);
                  final pct = (kwh / maxKwh).clamp(0.0, 1.0);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // left big kWh
                      SizedBox(
                        width: 76,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayKwh.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_unit, style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // middle progress bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 18,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.grey[200]),
                                ),
                                FractionallySizedBox(
                                  widthFactor: pct,
                                  child: Container(height: 18, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.black87)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(label, style: const TextStyle(color: Colors.black38, fontSize: 12)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // right hours
                      SizedBox(
                        width: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${hours.toStringAsFixed(1)} hours', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
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
