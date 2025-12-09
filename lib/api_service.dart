import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  // ---------- TEST ----------
  static Future<Map<String, dynamic>> ping() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/ping");
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Ping failed: ${res.statusCode} ${res.body}");
    }
    return jsonDecode(res.body);
  }

  // ---------- SETTINGS ----------
  static Future<Map<String, dynamic>> getSettings() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/settings");
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Failed to load settings");
    }
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updatePrice(num pricePerKwh) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/settings/price");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"pricePerKwh": pricePerKwh}),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to update price");
    }
    return jsonDecode(res.body);
  }

  // ---------- ROOMS ----------
  static Future<List<dynamic>> getRooms() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/rooms");
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception("Failed to load rooms");
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addRoom(String name) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/rooms");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name}),
    );
    if (res.statusCode != 200) throw Exception("Failed to add room");
    return jsonDecode(res.body);
  }

  // ---------- APPLIANCES ----------
  static Future<List<dynamic>> getAppliances({String? roomId}) async {
    final q = (roomId != null && roomId.isNotEmpty) ? "?roomId=$roomId" : "";
    final url = Uri.parse("${ApiConfig.baseUrl}/api/appliances$q");
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception("Failed to load appliances");
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addAppliance(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/appliances");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) throw Exception("Failed to add appliance");
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getApplianceStats(
    String applianceId,
  ) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/api/appliances/$applianceId/stats",
    );
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception("Failed to load stats");
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getApplianceCarbon(
    String applianceId,
  ) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/api/appliances/$applianceId/carbon",
    );
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception("Failed to load carbon");
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getApplianceHistory(String applianceId) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/api/appliances/$applianceId/history",
    );
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception("Failed to load history");
    return jsonDecode(res.body);
  }

  // ---------- DEVICES ----------
  static Future<List<dynamic>> getDevices() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/devices");
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception("Failed to load devices");
    return jsonDecode(res.body);
  }

  static Future<dynamic> deviceOn(String deviceId) async {
    debugPrint("⚡ Flutter: calling backend device ON -> $deviceId");

    final url = Uri.parse("${ApiConfig.baseUrl}/api/devices/$deviceId/on");
    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception("Failed to turn on: ${res.statusCode} ${res.body}");
    }

    return jsonDecode(res.body);
  }

  static Future<dynamic> deviceOff(String deviceId) async {
    debugPrint("⚡ Flutter: calling backend device OFF -> $deviceId");

    final url = Uri.parse("${ApiConfig.baseUrl}/api/devices/$deviceId/off");
    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception("Failed to turn off: ${res.statusCode} ${res.body}");
    }

    return jsonDecode(res.body);
  }
}
