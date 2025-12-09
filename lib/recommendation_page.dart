import 'package:flutter/material.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({Key? key}) : super(key: key);

  Widget _buildCard({required Color start, required Color end, required String title, required String subtitle, required String badge, required String actionLabel, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [const Icon(Icons.savings, size: 14), const SizedBox(width: 6), Text(badge, style: const TextStyle(fontSize: 12))]),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      onPressed: () {},
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text(actionLabel)),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 36, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
          title: Row(
            children: [
              const Icon(Icons.bolt, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Smart Energy-saving Recommendations',
                  style: const TextStyle(color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.green[800],
            unselectedLabelColor: Colors.blueGrey,
            indicatorColor: Colors.green[800],
            tabs: const [Tab(text: 'Product Recommendations')],
          ),
        ),
        body: TabBarView(children: [
          // Product tab only
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCard(
                  start: const Color(0xFFDDE7FF),
                  end: const Color(0xFFB8CBFF),
                  title: 'Smart Charger X1',
                  subtitle: 'Fast, efficient EV charging with schedule support',
                  badge: 'Recommended',
                  actionLabel: 'View',
                  icon: Icons.ev_station,
                ),
                const SizedBox(height: 12),
                _buildCard(
                  start: const Color(0xFFFFF1D6),
                  end: const Color(0xFFFFE6B8),
                  title: 'Energy Monitor Pro',
                  subtitle: 'Measure device-level energy use and suggestions',
                  badge: 'Top Pick',
                  actionLabel: 'View',
                  icon: Icons.speed,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
