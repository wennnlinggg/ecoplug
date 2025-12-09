import 'package:flutter/material.dart';

// Temporarily disable firebase usage so app can be built on emulator
// Original backed up at lib/backups/test_list_page.dart.bak
class TestListPage extends StatelessWidget {
  const TestListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Test Data')),
      body: const Center(child: Text('Realtime test disabled (firebase unavailable)')),
    );
  }
}
