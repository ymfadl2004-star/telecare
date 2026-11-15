import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const TeleCareApp());
}

class TeleCareApp extends StatefulWidget {
  const TeleCareApp({super.key});
  @override
  State<TeleCareApp> createState() =>
      _TeleCareAppState();
}

class _TeleCareAppState
    extends State<TeleCareApp> {
  String? role;
  bool demo = true;
  int tab = 0;

  final List> vitals = [
    {
      't': 'Blood Pressure',
      'v': '122 / 78 mmHg',
      's': 'DEMO DATA',
      'd': 'Simulated Cuff'
    },
    {
      't': 'Heart Rate',
      'v': '74 BPM',
      's': 'DEMO DATA',
      'd': 'Optical HR'
    },
    {
      't': 'Temperature',
      'v': '36.8 C',
      's': 'DEMO DATA',
      'd': 'Thermometer'
    },
    {
      't': 'SpO2',
      'v': '98 %',
      's': 'DEMO STALE',
      'd': 'Pulse Oximeter'
    },
    {
      't': 'Glucose',
      'v': 'No Reading',
      's': 'MISSING',
      'd': 'Unpaired'
    },
  ];

  final List> appts = [
    {
      'sp': 'Cardiology',
      'dt': '2026-11-20 11:00',
      'st': 'CONFIRMED'
    },
    {
      'sp': 'Internal Med',
      'dt': '2026-11-25 14:00',
      'st': 'PENDING'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeleCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed:
            const Color(0xFF0A4D68),
      ),
      home: role == null
          ? _buildLogin()
          : _buildHome(),
    );
  }

  Widget _buildLogin() {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monitor_heart,
                  size: 48,
                  color: Color(0xFF0A4D68),
                ),
                const SizedBox(height: 12),
                const Text(
                  'TeleCare Platform',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => setState(
                    () => role = 'PATIENT',
                  ),
                  child: const Text(
                    'Login as Patient',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => setState(
                    () => role = 'DOCTOR',
                  ),
                  child: const Text(
                    'Login as Doctor',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => setState(
                    () => role = 'ADMIN',
                  ),
                  child: const Text(
                    'Login as Admin',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    return Scaffold(
      appBar: AppBar(
        title: Text('TeleCare ($role)'),
        actions: [
          Switch(
            value: demo,
            onChanged: (v) =>
                setState(() => demo = v),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                setState(() => role = null),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) =>
            setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Vitals',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline),
            label: 'ECG',
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(Icons.bluetooth),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.call),
            label: 'SOS',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (tab == 1) return const ECGBox();
    if (tab == 2) return _buildAppts();
    if (tab == 3) return _buildDevs();
    if (tab == 4) return _buildSos();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: vitals.map((item) {
        final val = demo
            ? item['v']!
            : '-- (No Device)';
        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          child: ListTile(
            title: Text(
              item['t']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Value: $val\n'
              'Source: ${item['d']}',
            ),
            trailing: Chip(
              label: Text(item['s']!),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppts() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton(
          onPressed: () {
            setState(() {
              appts.insert(0, {
                'sp': 'Cardiology',
                'dt': '2026-12-01 10:00',
                'st': 'PENDING',
              });
            });
          },
          child: const Text(
            'New Appointment (Pending)',
          ),
        ),
        const SizedBox(height: 12),
        ...appts.map(
          (a) => Card(
            child: ListTile(
              title: Text(a['sp']!),
              subtitle: Text(a['dt']!),
              trailing: Text(a['st']!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevs() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text('ECG Patch'),
            subtitle: Text('Pending Protocol'),
            trailing: Text('UNSUPPORTED'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text('BP Cuff Monitor'),
            subtitle: Text('BLE Standard'),
            trailing: Text('DISCONNECTED'),
          ),
        ),
      ],
    );
  }

  Widget _buildSos() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Emergency Contact:\n'
            'Ahmed Hassan (+201000000000)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call),
            label: const Text(
              'Open Phone Dialer',
            ),
          ),
        ],
      ),
    );
  }
}

class ECGBox extends StatefulWidget {
  const ECGBox({super.key});
  @override
  State<ECGBox> createState() =>
      _ECGBoxState();
}

class _ECGBoxState extends State<ECGBox> {
  final ListQueue<double> buf =
      ListQueue<double>(120);
  Timer? t;
  bool active = false;
  int k = 0;

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  void toggle() {
    if (active) {
      t?.cancel();
      setState(() {
        active = false;
        buf.clear();
      });
    } else {
      setState(() => active = true);
      t = Timer.periodic(
        const Duration(milliseconds: 40),
        (_) {
          setState(() {
            k++;
            final p = (k % 30) / 30.0;
            double v =
                math.sin(p * 6.28) * 0.1;
            if (p > 0.45 && p < 0.52) {
              v = 1.0;
            }
            if (buf.length >= 120) {
              buf.removeFirst();
            }
            buf.addLast(v);
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FilledButton(
            onPressed: toggle,
            child: Text(
              active
                  ? 'Stop Demo ECG'
                  : 'Start Demo ECG Stream',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            width: double.infinity,
            color: const Color(0xFF0F172A),
            child: active
                ? CustomPaint(
                    painter: WavePainter(
                      buf.toList(),
                    ),
                  )
                : const Center(
                    child: Text(
                      'No Verified ECG Device.\n'
                      'Tap Start Demo ECG.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final List<double> pts;
  WavePainter(this.pts);
  @override
  void paint(Canvas c, Size s) {
    if (pts.length < 2) return;
    final p = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final path = Path();
    final dx = s.width / 120;
    final mid = s.height / 2;
    for (int i = 0; i < pts.length; i++) {
      final x = i * dx;
      final y =
          mid - (pts[i] * s.height * 0.35);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(
    covariant WavePainter old,
  ) =>
      true;
}
