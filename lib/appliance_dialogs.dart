import 'package:flutter/material.dart';

String _num(dynamic v, {int fraction = 2}) {
  if (v == null) return "0";
  final n = (v is num) ? v : num.tryParse(v.toString()) ?? 0;
  return n.toStringAsFixed(fraction);
}

Widget _infoRow(String label, String value, {IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

// -------------------- STATS DIALOG --------------------
Future<void> showStatsDialog(BuildContext context, Map<String, dynamic> stats) {
  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text("Stats - ${stats["name"] ?? ""}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow(
              "Energy (kWh)",
              _num(stats["kwh"], fraction: 3),
              icon: Icons.bolt,
            ),
            _infoRow(
              "Power (W)",
              _num(stats["powerW"], fraction: 0),
              icon: Icons.flash_on,
            ),
            _infoRow(
              "Voltage (V)",
              _num(stats["voltageV"], fraction: 1),
              icon: Icons.electrical_services,
            ),
            _infoRow(
              "Current (A)",
              _num(stats["currentA"], fraction: 3),
              icon: Icons.cable,
            ),
            _infoRow(
              "Runtime (hrs)",
              _num(stats["runtimeHours"], fraction: 2),
              icon: Icons.timer,
            ),
            const Divider(),
            _infoRow(
              "Estimated Cost Today",
              "\$ ${_num(stats["costToday"], fraction: 2)}",
              icon: Icons.attach_money,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

// -------------------- CARBON DIALOG --------------------
Future<void> showCarbonDialog(
  BuildContext context,
  Map<String, dynamic> carbon,
) {
  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Carbon Impact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow(
              "Monthly Energy (kWh)",
              _num(carbon["monthKwh"], fraction: 3),
              icon: Icons.bolt,
            ),
            _infoRow(
              "CO₂ (kg)",
              _num(carbon["co2"], fraction: 3),
              icon: Icons.cloud,
            ),
            _infoRow(
              "Tree Offset (approx.)",
              _num(carbon["trees"], fraction: 2),
              icon: Icons.park,
            ),
            _infoRow(
              "Driving Hours (approx.)",
              _num(carbon["drivingHours"], fraction: 2),
              icon: Icons.directions_car,
            ),
            const SizedBox(height: 6),
            const Text(
              "These are simple estimates for awareness.",
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

// -------------------- HISTORY DIALOG --------------------
Future<void> showHistoryDialog(BuildContext context, List<dynamic> history) {
  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Energy History"),
        content: SizedBox(
          width: 360,
          child: history.isEmpty
              ? const Text("No history yet.")
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(height: 10),
                  itemBuilder: (_, i) {
                    final h = history[i] as Map<String, dynamic>;
                    final ts = h["timestamp"];
                    final dt = (ts is int)
                        ? DateTime.fromMillisecondsSinceEpoch(ts)
                        : DateTime.tryParse(ts?.toString() ?? "");

                    final timeText = dt == null
                        ? "-"
                        : "${dt.year}-${dt.month.toString().padLeft(2, "0")}-${dt.day.toString().padLeft(2, "0")} "
                              "${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}";

                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Text(
                          "${_num(h["totalKwh"], fraction: 3)} kWh",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}
