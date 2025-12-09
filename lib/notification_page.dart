import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // sample notifications; each entry has a 'read' flag we update locally
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Sustainable Life!',
      'time': '12:00 PM',
      'body': 'Start your day sustainably — switching off now saves energy and supports your Net Zero goals.',
      'read': false,
    },
    {
      'id': '2',
      'title': 'Monitor, Schedule and Control',
      'time': '11:00 AM',
      'body': 'Monitor, Schedule and Control your device to save both energy and the planet.',
      'read': false,
    },
    {
      'id': '3',
      'title': 'Get Connected Now',
      'time': '11:00 AM',
      'body': 'Connect your first device and see how easy it is to start saving energy!',
      'read': false,
    },
    {
      'id': '4',
      'title': 'Welcome to Eco Plug!',
      'time': '10:50 AM',
      'body': 'Your journey toward a smarter, greener home starts here.',
      'read': false,
    }
  ];

  void _markRead(int index) {
    if (!_notifications[index]['read']) {
      setState(() => _notifications[index]['read'] = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as read')));
    }
  }

  void _removeNotification(int index) {
    final removed = _notifications.removeAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${removed['title']}"')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? const Center(child: Text('No notifications'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: _notifications.length + 1,
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Today', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                    );
                  }
                  final idx = i - 1;
                  final n = _notifications[idx];

                  return Column(
                    children: [
                      Dismissible(
                        key: ValueKey(n['id'] ?? idx),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _removeNotification(idx),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: (n['read'] == true) ? Colors.black45 : Colors.black87,
                                  ),
                                ),
                              ),
                              if (n['read'] == true) const Icon(Icons.check, size: 16, color: Colors.green)
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(n['body'] ?? '', style: TextStyle(color: (n['read'] == true) ? Colors.black38 : Colors.black54)),
                          ),
                          trailing: Text(n['time'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          onTap: () => _markRead(idx),
                        ),
                      ),
                      const Divider(height: 20),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
