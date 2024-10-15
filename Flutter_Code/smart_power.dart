import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui'; // Import for ImageFilter

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SensorDataDisplay(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
    );
  }
}

class SensorDataDisplay extends StatefulWidget {
  @override
  _SensorDataDisplayState createState() => _SensorDataDisplayState();
}

class _SensorDataDisplayState extends State<SensorDataDisplay> {
  String ultrasonicDistance = 'Loading...';
  String ldrValue = 'Loading...';
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchSensorData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchSensorData() async {
    final apiUrl =
        'https://api.thingspeak.com/channels/2596814/feeds.json?api_key=FJIGDGIC3F0X15OC&results=1';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ultrasonicDistance = data['feeds'][0]['field1'] ?? 'N/A';
          ldrValue = data['feeds'][0]['field2'] ?? 'N/A';
        });
      } else {
        setState(() {
          ultrasonicDistance = 'Error fetching data';
          ldrValue = 'Error fetching data';
        });
      }
    } catch (e) {
      setState(() {
        ultrasonicDistance = 'Error fetching data';
        ldrValue = 'Error fetching data';
      });
    }
  }

  String interpretLDRValue(String ldrValue) {
    try {
      double value = double.parse(ldrValue);
      return value > 500 ? "ON" : "OFF"; // Show ON/OFF based on LDR threshold
    } catch (e) {
      return "Error";
    }
  }

  String interpretUltrasonicValue(String distance) {
    try {
      double value = double.parse(distance);
      return value > 10 ? "Turn OFF" : "Turn ON"; // Example condition for water
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMART POWER', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF1F1F1F),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildCircularSensorContainer(
                      'WATER', interpretUltrasonicValue(ultrasonicDistance), Icons.water_drop, context),
                ),
                Expanded(
                  child: _buildCircularSensorContainer(
                      'LIGHT', interpretLDRValue(ldrValue), Icons.lightbulb, context),
                ),
                Expanded(
                  child: _buildCircularSensorContainer(
                      'FAN', interpretLDRValue(ldrValue), Icons.air, context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularSensorContainer(
      String title, String value, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              title: title,
              value: value,
              sensorType: title == 'Water' ? 'Ultrasonic' : 'LDR',
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        padding: EdgeInsets.all(12.0),
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: Color(0xFF2E2E2E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8.0,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 30),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String title;
  final String value;
  final String sensorType;

  DetailScreen({
    required this.title,
    required this.value,
    required this.sensorType,
  });

  String getMotorAction(String value) {
    return value == 'Turn ON' || value == 'Turn OFF'
        ? (value == 'Turn ON' ? 'Turn ON Motor' : 'Turn OFF Motor')
        : value;
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (title) {
      case 'WATER':
        icon = Icons.water_drop;
        break;
      case 'LIGHT':
        icon = Icons.lightbulb;
        break;
      case 'FAN':
        icon = Icons.air;
        break;
      default:
        icon = Icons.device_unknown; // Default icon if none match
    }

    return Scaffold(
      body: Stack(
        children: [
          // Blurred background
          Opacity(
            opacity: 0.8,
            child: Container(
              color: Colors.black,
              child: Center(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // Add overlay
                  ),
                ),
              ),
            ),
          ),
          // Rectangular detail container with sharp corners
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: 300.0, // Width remains the same
              height: 300.0, // Height remains the same
              decoration: BoxDecoration(
                color: Color(0xFF2E2E2E),
                // Removed borderRadius for sharp corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.blueAccent, size: 40), // Icon for each sensor
                  SizedBox(height: 16.0),
                  Text(
                    '$title STATUS:',
                    style: TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    getMotorAction(value),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('OK', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
