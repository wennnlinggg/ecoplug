import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'image_pages.dart' as pages;
import 'profile_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';
import 'energy_dashboard_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Layout',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      routes: {
        '/setAlarm': (ctx) => SetAlarmPage(),
        '/login': (ctx) => const LoginScreen(),
        '/goals': (ctx) => const pages.GoalsPage(),
        '/netzero': (ctx) => NetZeroPage(),
        '/eco': (ctx) => EcoPlugPage(),
        '/tips': (ctx) => TipsPage(),
        '/learn': (ctx) => LearnPage(),
        '/notification': (ctx) => const NotificationsPage(),
      },
      home: const WelcomePage(),
    );
  }
}

// Reusable app logo widget used on Welcome and Login
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.green[400], borderRadius: BorderRadius.circular(size * 0.18)),
      alignment: Alignment.center,
      child: Icon(Icons.bolt, color: Colors.white, size: size * 0.5),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // logo (use shared AppLogo widget)
                SizedBox(width: 120, height: 120, child: Center(child: AppLogo(size: 120))),
                const SizedBox(height: 18),
                const Text('Eco Plug', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                const SizedBox(height: 8),
                const Text('Powering a Smarter, Greener Future', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Eco Plug makes it easy to understand and manage your electricity use—one smart plug at a time.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 8),
                const Text('We’re here to help you save energy, reduce carbon emissions, and make everyday choices that are kinder to the planet. ', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 8),
                const Text('Let’s build greener habits together and take a step toward Net Zero 2050.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 8),
                const Text('Join us and make every watt count.', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Log in', style: TextStyle(fontSize: 16))),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(backgroundColor: Colors.grey[100], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpPage())),
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Create account', style: TextStyle(color: Colors.black87, fontSize: 16))),
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(height: 12),
                // use existing LoginCard widget
                LoginCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black54),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 0))),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 0))),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/welcome.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    color: const Color(0xFFF5F5F5),
                    alignment: Alignment.center,
                    child: const Text('Preview image not found', style: TextStyle(color: Colors.black45)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      pages.HomePage(),
      pages.EnergyPage(),
      UserProfilePage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: tabs[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        notchMargin: 6,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                selected: _selectedIndex == 0,
                onTap: () => _onNavTap(0),
              ),
              _NavItem(
                icon: Icons.bolt_outlined,
                selected: _selectedIndex == 1,
                onTap: () => _onNavTap(1),
              ),
              const SizedBox(width: 56), // space for FAB if any
              _NavItem(
                icon: Icons.person_outline,
                selected: _selectedIndex == 2,
                onTap: () => _onNavTap(2),
              ),
              _NavItem(
                icon: Icons.more_horiz,
                selected: _selectedIndex == 3,
                onTap: () => _onNavTap(3),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.onTap, this.selected = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Icon(
          icon,
          size: selected ? 28 : 22,
          color: selected ? Theme.of(context).colorScheme.primary : Colors.black54,
        ),
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(onPressed: () async { await Navigator.of(context).pushNamed('/setAlarm'); await _loadAlarms(); }, icon: const Icon(Icons.add)),
          ],
        ),
        backgroundColor: Colors.white,
        body: _alarms.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.assignment_outlined, size: 120, color: Colors.black26),
                    SizedBox(height: 12),
                    Text('Nothing here yet', style: TextStyle(color: Colors.black45)),
                  ],
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
                  // build repeat string (capitalize day names and join with commas)
                  String repeatToString(dynamic rep) {
                    try {
                      if (rep is List && rep.isNotEmpty) {
                        return rep.map((e) {
                          final s = e?.toString() ?? '';
                          if (s.isEmpty) return s;
                          return s[0].toUpperCase() + s.substring(1);
                        }).join(',');
                      }
                    } catch (_) {}
                    return '';
                  }

                  final repeatStr = repeatToString(a['repeat']);
                  // build short day names like Mon, Tue, ...
                  String repeatShort() {
                    try {
                      final rep = a['repeat'];
                      if (rep is List && rep.isNotEmpty) {
                        final map = {
                          'sunday': 'Sun',
                          'monday': 'Mon',
                          'tuesday': 'Tue',
                          'wednesday': 'Wed',
                          'thursday': 'Thu',
                          'friday': 'Fri',
                          'saturday': 'Sat'
                        };
                        return rep.map((e) {
                          final s = (e ?? '').toString().toLowerCase();
                          return map[s] ?? (s.isNotEmpty ? (s[0].toUpperCase() + s.substring(1)) : '');
                        }).where((x) => x.isNotEmpty).join(', ');
                      }
                    } catch (_) {}
                    return '';
                  }

                  final repeatShortStr = repeatShort();
                  final displayTitle = (label?.toString() ?? '').isNotEmpty ? label.toString() : '${fmt(sh, sm)} - ${fmt(eh, em)}';

                  return ListTile(
                    title: Text(displayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      (repeatShortStr.isEmpty ? (enabled ? 'On' : 'Off') : repeatShortStr + ' ; ' + (enabled ? 'On' : 'Off')),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: Switch(value: enabled, onChanged: (v) => _toggleEnabled(i, v)),
                    onTap: () async {
                      await Navigator.of(context).pushNamed('/setAlarm', arguments: {'alarm': a, 'index': i});
                      await _loadAlarms();
                    },
                  );
                },
              ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient and title
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    Text('Eco Plug', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28, color: Colors.green[900])),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageProfilePage())),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 28, color: Colors.grey[700]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageProfilePage())),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Set name', style: TextStyle(fontSize: 16)),
                                Icon(Icons.chevron_right, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Replace cards with a LoginCard that mirrors the attached design
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    LoginCard(),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
        // add FAB to create a new alarm
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetAlarmPage())),
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class SetAlarmPage extends StatefulWidget {
  const SetAlarmPage({super.key});

  @override
  State<SetAlarmPage> createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage> {
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 8, minute: 0);
  bool _vibrate = true;
  // per-alarm device switch state
  bool _switchOn = true;
  // repeat days stored as lowercase keys, e.g. 'sunday', 'monday', ...
  final Set<String> _repeatDays = <String>{};
  Map<String, dynamic>? _editingAlarm;
  int? _editingIndex;
  bool _inited = false;

  Future<void> _pickStart() async {
    final t = await showTimePicker(context: context, initialTime: _start);
    if (t != null) setState(() => _start = t);
  }

  Future<void> _pickEnd() async {
    final t = await showTimePicker(context: context, initialTime: _end);
    if (t != null) setState(() => _end = t);
  }

  String _fmt(TimeOfDay t) => t.format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(_editingIndex != null ? 'Edit Alarm' : 'Set Alarm'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text('Save', style: TextStyle(color: Colors.green)),
          )
        ],
      ),
      backgroundColor: const Color(0xFFF6FBF4),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, MediaQuery.of(context).viewInsets.bottom + 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _timeCard('Start time', _fmt(_start), _pickStart),
              const SizedBox(height: 12),
              _timeCard('End time', _fmt(_end), _pickEnd),
              const SizedBox(height: 12),
              // Repeat selection (Sun - Sat) — render on one row and show selected time/state below
              const Text('Repeat', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Builder(builder: (ctx) {
                final days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
                final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                final List<bool> isSelected = days.map((d) => _repeatDays.contains(d)).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ToggleButtons(
                        isSelected: isSelected,
                        borderRadius: BorderRadius.circular(20),
                        selectedColor: Colors.white,
                        fillColor: Colors.green.shade300,
                        color: Colors.black87,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
                        children: labels.map((l) => Text(l, style: const TextStyle(fontWeight: FontWeight.w600))).toList(),
                        onPressed: (idx) {
                          setState(() {
                            final key = days[idx];
                            if (_repeatDays.contains(key)) {
                              _repeatDays.remove(key);
                            } else {
                              _repeatDays.add(key);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    // header: Switch 1 with chevron
                    ListTile(
                      title: const Text('Switch 1', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Switch(value: _switchOn, onChanged: (v) => setState(() => _switchOn = v)),
                        const SizedBox(width: 8),
                      ]),
                      onTap: () => setState(() => _switchOn = !_switchOn),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('Default'),
                      subtitle: const Text('Default'),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.vibration),
                      title: const Text('Vibrate'),
                      trailing: Switch(value: _vibrate, onChanged: (v) => setState(() => _vibrate = v)),
                      onTap: () => setState(() => _vibrate = !_vibrate),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.label_outline),
                      title: const Text('Label'),
                      subtitle: Text(_editingAlarm?['label']?.toString() ?? 'None'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_editingIndex != null)
                Center(
                  child: TextButton(
                    onPressed: _deleteAlarm,
                    child: const Text('Delete Alarm', style: TextStyle(color: Colors.red)),
                  ),
                ),
              
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('alarms') ?? <String>[];
    final map = {
      'startHour': _start.hour,
      'startMinute': _start.minute,
      'endHour': _end.hour,
      'endMinute': _end.minute,
      'vibrate': _vibrate,
      'switchOn': _switchOn,
      'enabled': true,
      'label': _editingAlarm?['label'] ?? '',
      'repeat': _repeatDays.toList(),
    };

    if (_editingIndex != null && _editingIndex! >= 0 && _editingIndex! < list.length) {
      list[_editingIndex!] = jsonEncode(map);
    } else {
      list.add(jsonEncode(map));
    }
    await prefs.setStringList('alarms', list);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteAlarm() async {
    if (_editingIndex == null) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('alarms') ?? <String>[];
    if (_editingIndex! >= 0 && _editingIndex! < list.length) {
      list.removeAt(_editingIndex!);
      await prefs.setStringList('alarms', list);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final alarm = args['alarm'];
      final idx = args['index'];
      if (alarm is Map<String, dynamic>) {
        _editingAlarm = alarm;
        _editingIndex = idx is int ? idx : null;
        try {
          final sh = (alarm['startHour'] ?? 0) as int;
          final sm = (alarm['startMinute'] ?? 0) as int;
          final eh = (alarm['endHour'] ?? sh) as int;
          final em = (alarm['endMinute'] ?? sm) as int;
          _start = TimeOfDay(hour: sh, minute: sm);
          _end = TimeOfDay(hour: eh, minute: em);
          _vibrate = (alarm['vibrate'] ?? true) as bool;
          // load repeat days if present
          try {
            _repeatDays.clear();
            final rep = alarm['repeat'];
            if (rep is List) {
              for (final e in rep) {
                try {
                  final s = (e ?? '').toString().toLowerCase();
                  if (s.isNotEmpty) _repeatDays.add(s);
                } catch (_) {}
              }
            }
          } catch (_) {}
          try {
            _switchOn = (alarm['switchOn'] ?? true) as bool;
          } catch (_) {}
        } catch (_) {}
      }
    }
    _inited = true;
  }

  Widget _dayChip(String key, String label) {
    final selected = _repeatDays.contains(key);
    return FilterChip(
      selected: selected,
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      showCheckmark: false,
      labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      backgroundColor: Colors.white,
      selectedColor: Colors.green.shade100,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
      onSelected: (v) {
        setState(() {
          if (v) {
            _repeatDays.add(key);
          } else {
            _repeatDays.remove(key);
          }
        });
      },
    );
  }


  Widget _timeCard(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
        child: Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 18))])),
            IconButton(onPressed: onTap, icon: const Icon(Icons.access_time_outlined)),
          ],
        ),
      ),
    );
  }
}

// _SmallCard and _LargeCard were removed because they are no longer used.

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class ManageProfilePage extends StatelessWidget {
  const ManageProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [Colors.green.shade100, Colors.green.shade50.withAlpha(153)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Manage Profile', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // big avatar
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black12, width: 2),
                  ),
                  child: const Icon(Icons.person, size: 64, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: const [
                    _FormRow(label: 'Name'),
                    SizedBox(height: 12),
                    _FormRow(label: 'Gender'),
                    SizedBox(height: 12),
                    _FormRow(label: 'Birthday', trailingIcon: Icons.calendar_today),
                    SizedBox(height: 12),
                    _FormRow(label: 'Location'),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _accepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _valid => _nameController.text.trim().isNotEmpty && _emailController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty && _accepted;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pwd = _passwordController.text;
    final prefs = await SharedPreferences.getInstance();
    final map = {'name': name, 'email': email, 'password': pwd};
    await prefs.setString('account', jsonEncode(map));
    // also save a profile name so the profile page shows it immediately
    await prefs.setString('profile_name', name);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Create account', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Full name'),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Your full name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                const Text('Email'),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                const Text('Password'),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '********',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                Row(children: [
                  Checkbox(value: _accepted, onChanged: (v) => setState(() => _accepted = v ?? false)),
                  const Expanded(child: Text('I accept the terms and privacy policy'))
                ]),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: _valid ? _save : null,
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Sign up')),
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

class _FormRow extends StatelessWidget {
  const _FormRow({super.key, required this.label, this.trailingIcon});
  final String label;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              if (trailingIcon != null) Icon(trailingIcon, color: Colors.grey[600]) else const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginCardState extends State<LoginCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _remember = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // centered logo
            const AppLogo(size: 64),
            const SizedBox(height: 12),
            const Text('Hi, Welcome Back! 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            // Email
            Align(alignment: Alignment.centerLeft, child: const Text('Email')),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'example@gmail.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),

            // Password
            Align(alignment: Alignment.centerLeft, child: const Text('Password')),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                const Text('Remember Me'),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  // check for stored account in SharedPreferences first
                  final email = _emailController.text.trim();
                  final pwd = _passwordController.text;
                  var ok = false;
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final stored = prefs.getString('account');
                    if (stored != null) {
                      final map = jsonDecode(stored) as Map<String, dynamic>;
                      if ((map['email'] ?? '') == email && (map['password'] ?? '') == pwd) ok = true;
                    }
                  } catch (_) {}

                  // fallback dev credential
                  if (!ok && email == 'abcde' && pwd == '12345') ok = true;

                  if (ok) {
                    // after successful login, go to preview page first
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PreviewPage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
                  }
                },
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Log in')),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Forgot password?', style: TextStyle(color: Colors.red))),

            const Divider(),
            const SizedBox(height: 8),
            Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('or')), Expanded(child: Divider())]),
            const SizedBox(height: 8),

            // Social buttons
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata, color: Colors.black),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Continue with Google')),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.apple, color: Colors.black),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Continue with Apple')),
              ),
            ),

            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? "),
              Builder(builder: (ctx) {
                return TextButton(
                    onPressed: () async {
                      final res = await Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const SignUpPage()));
                      if (res == true) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Account created. Please log in.')));
                      }
                    },
                    child: const Text('Sign Up', style: TextStyle(color: Colors.green)));
              })
            ]),
          ],
        ),
      ),
    );
  }
}

class NetZeroPage extends StatelessWidget {
  const NetZeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    const content = '''Net Zero refers to the goal of reducing greenhouse gas emissions to zero by 2050. This ambitious target is essential to preventing the worst effects of climate change and limiting global warming to 1.5°C above pre-industrial levels. Achieving Net Zero requires a combination of reducing emissions and actively removing carbon from the atmosphere.

One of the primary strategies for reaching Net Zero is transitioning to renewable energy sources such as solar, wind, and hydroelectric power. These alternatives to fossil fuels help minimize carbon emissions while promoting sustainable energy consumption. Additionally, advances in carbon capture and storage technologies play a crucial role in removing existing greenhouse gases from the atmosphere, ensuring a cleaner environment. Governments and organizations worldwide have recognized the urgency of this goal, implementing policies and initiatives to drive progress. International agreements like the Paris Agreement have set clear objectives for emission reductions, urging countries to adopt sustainable practices. Businesses are also taking significant steps by committing to carbon neutrality, investing in green technologies, and enhancing energy efficiency in operations.

Despite these efforts, achieving Net Zero presents numerous challenges, including economic costs, technological limitations, and political obstacles. However, the transition also brings opportunities, such as the growth of green industries, job creation, and improved public health due to reduced air pollution. The shift toward sustainability requires collective action, fostering innovation and collaboration across various sectors. Individuals also play a vital role in contributing to Net Zero. Small lifestyle changes, such as using energy-efficient appliances, reducing waste, and advocating for climate-friendly policies, can have a meaningful impact. By making conscious choices and supporting sustainability efforts, individuals can help shape a greener future.

Reaching Net Zero by 2050 is a complex yet necessary endeavor. While challenges exist, global cooperation, technological advancements, and a commitment to sustainability can pave the way for a cleaner and healthier planet. Everyone—governments, businesses, and individuals—must take responsibility in ensuring that future generations inherit a world free from the devastating consequences of climate change.''';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Net Zero'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.asset(
                    'assets/images/a.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                  ),
                ),
              ),
            ),

            // title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('Net Zero', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),

            // scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EcoPlugPage extends StatelessWidget {
  const EcoPlugPage({super.key});

  static const String _bodyText = '''Eco Plug is an AI-powered app that helps you manage your home’s energy use more efficiently. It controls devices automatically and offers real-time energy data and savings tips.

Eco Plug is designed to enhance energy efficiency and reduce carbon emissions through AI-driven automation. It monitors real-time power usage, provides energy reports, and optimizes consumption by learning user habits.

With remote control via a mobile app or voice assistants, users can schedule appliances and reduce unnecessary power waste. Safety alerts detect abnormal usage, while a built-in carbon footprint tracker converts energy use into CO₂ emissions and offers eco-friendly recommendations.

By integrating smart energy solutions into daily life, Eco Plug makes sustainability effortless while helping users lower their environmental impact.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Plug'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.grey[100]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/b.png',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.green[50],
                        child: const Center(child: Icon(Icons.bedtime, size: 56, color: Colors.green)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(child: Text('Eco Plug', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87))),
                const SizedBox(height: 12),
                SelectableText(
                  _bodyText,
                  style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  textAlign: TextAlign.start,
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

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  static const String _bodyText = '''Tips for Saving Power:
●Use Smart Plugs to Manage Energy Consumption: Install AI-driven smart plugs like Eco Plug to automate the management of your household appliances and avoid unnecessary energy use.
●Optimize Energy Efficiency at Home: Set your smart plugs to turn off unused devices, particularly those that consume power in standby mode.
●Choose Energy-Saving Appliances: Replace old, inefficient devices with energy-efficient ones that work seamlessly with your smart plug, reducing your energy consumption even further.
●Educate and Share: Spread the word about the benefits of smart plugs and energy-saving solutions within your community, helping others contribute to the Net Zero goal.
●Advocate for Smart Energy Solutions: Support policies that promote the adoption of AI and energy-saving technologies in households, businesses, and governments.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips & Tricks'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.grey[100]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/d.png',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.green[50],
                        child: const Center(child: Icon(Icons.bedtime, size: 56, color: Colors.green)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(child: Text('Tips & Tricks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87))),
                const SizedBox(height: 12),
                SelectableText(
                  _bodyText,
                  style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  textAlign: TextAlign.start,
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

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  static const String _bodyText = '''Eco Plug helps users monitor, control, and optimize their electricity usage with real-time power tracking, AI-based energy optimization, and remote access. Here’s how it makes energy efficiency effortless:
●Reducing Wasted Energy: Many devices consume power even when switched off. Eco Plug detects and eliminates unnecessary standby energy use.
●Lowering Carbon Emissions: The plug converts electricity usage into CO₂ emissions, helping users track their environmental impact.
●Enhancing Energy Efficiency: AI analyzes usage patterns and suggests energy-saving habits, ensuring optimal power management.
●Remote Control for Convenience: Users can control appliances anytime, anywhere through a mobile app or voice assistants.
●By integrating these smart energy-saving features into daily life, Eco Plug empowers users to make sustainable choices with ease.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn How You Can Help'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.grey[100]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/c.png',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.green[50],
                        child: const Center(child: Icon(Icons.bedtime, size: 56, color: Colors.green)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(child: Text('Learn How You Can Help', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87))),
                const SizedBox(height: 12),
                SelectableText(
                  _bodyText,
                  style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  textAlign: TextAlign.start,
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


