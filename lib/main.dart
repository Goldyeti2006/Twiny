import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: ScanScreen()));
}

// ------------------------------------------------------------------
// SCREEN 1: SCAN SCREEN (Finds the ESP32)
// ------------------------------------------------------------------
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  // This UUID MUST match the 'SERVICE_UUID' in your ESP32 code
  final String _targetServiceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  void startScan() {
    setState(() {
      _scanResults.clear();
      _isScanning = true;
    });

    // Start scanning specifically for our Evil Twin's Service UUID
    FlutterBluePlus.startScan(
        withServices: [Guid(_targetServiceUUID)],
        timeout: const Duration(seconds: 10)
    );

    FlutterBluePlus.scanResults.listen((results) {
      if(mounted) {
        setState(() {
          _scanResults = results;
        });
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
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

          Expanded(
            child: ListView.separated(
              itemCount: _scanResults.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final device = result.device;
                final name = device.platformName.isNotEmpty ? device.platformName : "Unknown Device";
                final rssi = result.rssi;

                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(device.remoteId.toString()),
                  trailing: Text("$rssi dBm"),
                  tileColor: Colors.blue.withOpacity(0.05),

                  // --- HERE IS THE ONTAP SECTION ---
                  onTap: () {
                    // Stop scanning to save battery/bandwidth
                    FlutterBluePlus.stopScan();

                    // Navigate to the Control Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ControlScreen(device: device),
                      ),
                    );
                  },
                  // ---------------------------------
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// SCREEN 2: CONTROL SCREEN (Sends Commands)
// ------------------------------------------------------------------
class ControlScreen extends StatefulWidget {
  final BluetoothDevice device;

  const ControlScreen({super.key, required this.device});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  // These UUIDs must match your ESP32 code exactly
  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String commandUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  BluetoothCharacteristic? commandCharacteristic;
  bool isConnected = false;
  String statusText = "Connecting...";

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  Future<void> connectToDevice() async {
    try {
      await widget.device.connect();
      setState(() => statusText = "Discovering Services...");

      List<BluetoothService> services = await widget.device.discoverServices();

      var evilTwinService = services.firstWhere(
            (s) => s.uuid.toString() == serviceUUID,
        orElse: () => throw Exception("Service not found"),
      );

      commandCharacteristic = evilTwinService.characteristics.firstWhere(
            (c) => c.uuid.toString() == commandUUID,
        orElse: () => throw Exception("Command Char not found"),
      );

      setState(() {
        isConnected = true;
        statusText = "Connected & Ready";
      });

    } catch (e) {
      setState(() => statusText = "Error: $e");
    }
  }

  Future<void> sendCommand(String cmd) async {
    if (commandCharacteristic == null) return;
    await commandCharacteristic!.write(cmd.codeUnits);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sent command: $cmd")),
    );
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.platformName)),
      body: Center(
        child: !isConnected
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(statusText),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Status: $statusText", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => sendCommand("START"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text("START ATTACK", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => sendCommand("STOP"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text("STOP ATTACK", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}