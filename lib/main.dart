import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: ScanScreen()));
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // This list holds the devices we find
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // ask for permissions as soon as the app starts
    _checkPermissions();
  }

  // 1. Request Android Permissions
  Future<void> _checkPermissions() async {
    await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  // 2. Start Scanning for Devices
  void startScan() {
    // Clear the old list
    setState(() {
      _scanResults.clear();
      _isScanning = true;
    });

    // Start listening to the stream of scan results
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Update the UI whenever a new device is found
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
      });
    });

    // Stop the loading spinner after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isScanning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evil Twin Controller"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // The "Scan" Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: _isScanning ? null : startScan,
              icon: _isScanning
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.search),
              label: Text(_isScanning ? "Scanning..." : "Scan for ESP32"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),

          // The List of Found Devices
          Expanded(
            child: ListView.separated(
              itemCount: _scanResults.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final device = result.device;
                final name = device.platformName.isNotEmpty ? device.platformName : "Unknown Device";
                final id = device.remoteId.toString();
                final rssi = result.rssi;

                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(id),
                  trailing: Text("$rssi dBm"),
                  // Highlight our specific ESP32
                  tileColor: name == "ESP32_Control" ? Colors.green.withOpacity(0.1) : null,
                  onTap: () {
                    print("Tapped on $name");
                    // Next Module: We will add connection logic here
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}