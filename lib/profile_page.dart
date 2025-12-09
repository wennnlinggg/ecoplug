import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'set_name_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? _name;
  String? _gender;
  DateTime? _birthday;
  String? _location;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('profile_name');
    final gender = prefs.getString('profile_gender');
    final birthdayStr = prefs.getString('profile_birthday');
    final location = prefs.getString('profile_location');
    // If no explicit profile name saved, fall back to account name from sign-up
    String? fallbackName;
    try {
      final acct = prefs.getString('account');
      if (acct != null) {
        final m = jsonDecode(acct) as Map<String, dynamic>;
        final n = (m['name'] as String?)?.trim();
        if (n != null && n.isNotEmpty) fallbackName = n;
      }
    } catch (_) {}
    setState(() {
      _name = name ?? fallbackName;
      _gender = gender;
      if (birthdayStr != null) {
        try {
          _birthday = DateTime.parse(birthdayStr);
        } catch (_) {
          _birthday = null;
        }
      }
      _location = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFFE8F8EC), Color(0xFFF2F6F3)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header title (app may render its own title; kept minimal here)
                Center(
                  child: Text(
                    'Eco Plug',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),

                const SizedBox(height: 18),

                // Profile row: avatar + set name
                Material(
                  color: Colors.white,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetNamePage()));
                      if (result != null && result is Map) {
                        // validate returned map contains required keys
                        final name = (result['name'] as String?)?.trim();
                        final gender = result['gender'] as String?;
                        final birthdayStr = result['birthday'] as String?;
                        final location = (result['location'] as String?)?.trim();
                        if (name != null && name.isNotEmpty && gender != null && birthdayStr != null && location != null && location.isNotEmpty) {
                          DateTime? bd;
                          try {
                            bd = DateTime.parse(birthdayStr);
                          } catch (_) {
                            bd = null;
                          }
                          setState(() {
                            _name = name;
                            _gender = gender;
                            _birthday = bd;
                            _location = location;
                          });
                        } else {
                          // ignore incomplete result
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_outline, size: 30, color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_name ?? 'Set name', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(_location ?? 'Tap to edit', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Two small action cards side by side
                Row(
                  children: [
                    Expanded(
                      child: _SmallCard(
                        icon: Icons.lock_outline,
                        title: 'Password',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallCard(
                        icon: Icons.mail_outline,
                        title: 'Recovery Email',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Large tiles
                _LargeTile(
                  title: 'Manage homes',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageHomesPage())),
                ),

                const SizedBox(height: 12),

                _LargeTile(
                  title: 'Message Center',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MessageCenterPage())),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  const _SmallCard({required this.icon, required this.title, required this.onTap, super.key});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: Colors.black54),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeTile extends StatelessWidget {
  const _LargeTile({required this.title, required this.onTap, super.key});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class ManageHomesPage extends StatefulWidget {
  const ManageHomesPage({super.key});

  @override
  State<ManageHomesPage> createState() => _ManageHomesPageState();
}

class _ManageHomesPageState extends State<ManageHomesPage> {
  String? _familyName;
  String? _familyLocation;

  Future<void> _editFamilyName() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditFamilyNamePage(initial: _familyName)));
    if (result != null && result is String && result.isNotEmpty) {
      // persist
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('family_name', result);
      setState(() => _familyName = result);
    }
  }

  Future<void> _editFamilyLocation() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditFamilyLocationPage(initial: _familyLocation)));
    if (result != null && result is String && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('family_location', result);
      setState(() => _familyLocation = result);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFamilyName();
  }

  Future<void> _loadFamilyName() async {
    final prefs = await SharedPreferences.getInstance();
    final fam = prefs.getString('family_name');
    if (fam != null && mounted) setState(() => _familyName = fam);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFFE8F8EC), Color(0xFFF2F6F3)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage homes', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // breadcrumb / small labels
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: const [
                      Icon(Icons.place_outlined, size: 16, color: Colors.black54),
                      SizedBox(width: 6),
                      Text('Room', style: TextStyle(color: Colors.black54)),
                      SizedBox(width: 12),
                      Icon(Icons.grid_view_outlined, size: 16, color: Colors.black54),
                      SizedBox(width: 6),
                      Text('Device 0', style: TextStyle(color: Colors.black54)),
                      SizedBox(width: 12),
                      Icon(Icons.person_outline, size: 16, color: Colors.black54),
                      SizedBox(width: 6),
                      Text('Member', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),

                // Family Member card
                Material(
                  color: Colors.white,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Family Member', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[100],
                          child: const Icon(Icons.person_outline, color: Colors.black54),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, color: Colors.black54),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // List container with items
                Material(
                  color: Colors.white,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Family Name'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_familyName == null || _familyName!.isEmpty ? '' : _familyName!, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: _editFamilyName,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Family Location'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_familyLocation == null || _familyLocation!.isEmpty ? '' : _familyLocation!, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: _editFamilyLocation,
                      ),
                      const Divider(height: 1),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Rooms and Devices'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Material(
                  color: Colors.white,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    title: const Text('Theme Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Delete Family', style: TextStyle(color: Colors.red)),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditFamilyNamePage extends StatefulWidget {
  const EditFamilyNamePage({this.initial, super.key});
  final String? initial;

  @override
  State<EditFamilyNamePage> createState() => _EditFamilyNamePageState();
}

class EditFamilyLocationPage extends StatefulWidget {
  const EditFamilyLocationPage({this.initial, super.key});
  final String? initial;

  @override
  State<EditFamilyLocationPage> createState() => _EditFamilyLocationPageState();
}

class _EditFamilyLocationPageState extends State<EditFamilyLocationPage> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Location', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Family Location'),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                onPressed: () {
                  final name = _ctrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a family location')));
                    return;
                  }
                  Navigator.of(context).pop(name);
                },
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Save')),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _EditFamilyNamePageState extends State<EditFamilyNamePage> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Name', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Family Name'),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                onPressed: () {
                  final name = _ctrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a family name')));
                    return;
                  }
                  Navigator.of(context).pop(name);
                },
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Save')),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageCenterPage extends StatelessWidget {
  const MessageCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Center')),
      body: const Center(child: Text('Message Center - placeholder')),
    );
  }
}
