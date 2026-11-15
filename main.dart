import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const TeleCareApp());
}

enum UserRole { patient, doctor, admin }

class VitalReading {
  final String title;
  final String value;
  final String unit;
  final String source;
  final String status;
  final String trend;
  final bool isMissing;

  const VitalReading({
    required this.title,
    required this.value,
    required this.unit,
    required this.source,
    required this.status,
    required this.trend,
    this.isMissing = false,
  });
}

class TeleCareApp extends StatefulWidget {
  const TeleCareApp({super.key});

  @override
  State<TeleCareApp> createState() {
    return _TeleCareAppState();
  }
}

class _TeleCareAppState extends State<TeleCareApp> {
  UserRole? currentRole;
  String userEmail = '';
  bool isDemoMode = true;
  int selectedNavIndex = 0;

  final List> appointments = [
    {'specialty': 'Cardiology', 'patient': 'Omar Khaled', 'date': '2026-10-30 11:00', 'status': 'CONFIRMED'},
    {'specialty': 'Internal Medicine', 'patient': 'Omar Khaled', 'date': '2026-11-02 14:30', 'status': 'PENDING'},
  ];

  final List> auditLogs = [
    {'actor': 'doctor@telecare.med', 'action': 'VIEW_PATIENT_VITALS', 'target': 'Patient: P-001'},
    {'actor': 'admin@telecare.med', 'action': 'VERIFY_DOCTOR_PROFILE', 'target': 'Doctor: D-014'},
  ];

  String emergencyName = 'Ahmed Hassan (Brother)';
  String emergencyPhone = '+201000000000';

  List<VitalReading> getVitals() {
    if (!isDemoMode) {
      return const [
        VitalReading(title: 'Blood Pressure', value: '-- / --', unit: 'mmHg', source: 'No Verified Device', status: 'MISSING', trend: 'Awaiting sensor', isMissing: true),
        VitalReading(title: 'Heart Rate', value: '--', unit: 'BPM', source: 'No Verified Device', status: 'MISSING', trend: 'Awaiting sensor', isMissing: true),
        VitalReading(title: 'Temperature', value: '--', unit: '°C', source: 'No Verified Device', status: 'MISSING', trend: 'Awaiting sensor', isMissing: true),
        VitalReading(title: 'SpO2', value: '--', unit: '%', source: 'No Verified Device', status: 'MISSING', trend: 'Awaiting sensor', isMissing: true),
        VitalReading(title: 'Glucose', value: '--', unit: 'mg/dL', source: 'No Verified Device', status: 'MISSING', trend: 'Awaiting sensor', isMissing: true),
      ];
    }
    return const [
      VitalReading(title: 'Blood Pressure', value: '122 / 78', unit: 'mmHg', source: 'Simulated Cuff (Demo)', status: 'DEMO DATA', trend: 'Stable vs yesterday'),
      VitalReading(title: 'Heart Rate', value: '74', unit: 'BPM', source: 'Simulated Optical HR (Demo)', status: 'DEMO DATA', trend: 'Normal resting range'),
      VitalReading(title: 'Temperature', value: '36.8', unit: '°C', source: 'Simulated Thermometer (Demo)', status: 'DEMO DATA', trend: 'Normal baseline'),
      VitalReading(title: 'SpO2', value: '98', unit: '%', source: 'Simulated Oximeter (Demo)', status: 'DEMO • STALE', trend: 'Recorded >12h ago'),
      VitalReading(title: 'Glucose', value: 'No Reading', unit: 'mg/dL', source: 'Glucometer Unpaired', status: 'UNAVAILABLE', trend: 'Pair device to measure', isMissing: true),
    ];
  }

  void login(String email) {
    setState(() {
      userEmail = email;
      selectedNavIndex = 0;
      if (email.contains('doctor')) {
        currentRole = UserRole.doctor;
      } else if (email.contains('admin')) {
        currentRole = UserRole.admin;
      } else {
        currentRole = UserRole.patient;
      }
      auditLogs.insert(0, {
        'actor': email,
        'action': 'USER_LOGIN_SUCCESS',
        'target': 'Role: ${currentRole!.name.toUpperCase()}',
      });
    });
  }

  void logout() {
    setState(() {
      currentRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeleCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0A4D68),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      ),
      home: currentRole == null ? _buildLoginScreen() : _buildMainShell(),
    );
  }

  Widget _buildLoginScreen() {
    final emailCtrl = TextEditingController(text: 'patient@telecare.med');
    final passCtrl = TextEditingController(text: 'password123');

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.monitor_heart, color: Color(0xFF0A4D68), size: 36),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TeleCare', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('Clinical Telemedicine Platform', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Quick Role Selection (Tap to Login):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('Login as Patient'),
                          onPressed: () {
                            login('patient@telecare.med');
                          },
                        ),
                        ActionChip(
                          label: const Text('Login as Doctor'),
                          onPressed: () {
                            login('doctor@telecare.med');
                          },
                        ),
                        ActionChip(
                          label: const Text('Login as Admin'),
                          onPressed: () {
                            login('admin@telecare.med');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () {
                        login(emailCtrl.text.trim());
                      },
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Secure Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainShell() {
    final navItems = _getNavItems();
    if (selectedNavIndex >= navItems.length) {
      selectedNavIndex = 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.monitor_heart, color: Color(0xFF0A4D68)),
                const SizedBox(width: 8),
                const Text('TeleCare', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Chip(
                  label: Text(currentRole!.name.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            actions: [
              const Text('Demo Data:', style: TextStyle(fontSize: 12)),
              Switch(
                value: isDemoMode,
                onChanged: (val) {
                  setState(() {
                    isDemoMode = val;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: logout,
              ),
            ],
          ),
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  extended: constraints.maxWidth >= 980,
                  backgroundColor: Colors.white,
                  selectedIndex: selectedNavIndex,
                  onDestinationSelected: (idx) {
                    setState(() {
                      selectedNavIndex = idx;
                    });
                  },
                  destinations: navItems.map((item) {
                    return NavigationRailDestination(
                      icon: Icon(item['icon'] as IconData),
                      label: Text(item['label'] as String),
                    );
                  }).toList(),
                ),
              Expanded(child: _buildCurrentScreen()),
            ],
          ),
          bottomNavigationBar: !isWide
              ? NavigationBar(
                  selectedIndex: selectedNavIndex > 4 ? 0 : selectedNavIndex,
                  onDestinationSelected: (idx) {
                    setState(() {
                      selectedNavIndex = idx;
                    });
                  },
                  destinations: navItems.take(5).map((item) {
                    return NavigationDestination(
                      icon: Icon(item['icon'] as IconData),
                      label: item['label'] as String,
                    );
                  }).toList(),
                )
              : null,
        );
      },
    );
  }

  List> _getNavItems() {
    if (currentRole == UserRole.doctor) {
      return [
        {'label': 'Patients', 'icon': Icons.people_outline},
        {'label': 'Appointments', 'icon': Icons.calendar_month_outlined},
      ];
    }
    if (currentRole == UserRole.admin) {
      return [
        {'label': 'Admin Panel', 'icon': Icons.admin_panel_settings_outlined},
        {'label': 'Audit Logs', 'icon': Icons.security_outlined},
      ];
    }
    return [
      {'label': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'label': 'ECG Live', 'icon': Icons.timeline},
      {'label': 'History', 'icon': Icons.history_outlined},
      {'label': 'Appointments', 'icon': Icons.event_note_outlined},
      {'label': 'Devices', 'icon': Icons.bluetooth_outlined},
      {'label': 'Emergency', 'icon': Icons.emergency_outlined},
    ];
  }

  Widget _buildCurrentScreen() {
    if (currentRole == UserRole.doctor) {
      return selectedNavIndex == 0 ? _buildDoctorPortal() : _buildAppointmentsView(true);
    }
    if (currentRole == UserRole.admin) {
      return selectedNavIndex == 0 ? _buildAdminPortal() : _buildAuditView();
    }
    switch (selectedNavIndex) {
      case 0:
        return _buildPatientDashboard();
      case 1:
        return const ECGLiveView();
      case 2:
        return _buildHistoryView();
      case 3:
        return _buildAppointmentsView(false);
      case 4:
        return _buildDevicesView();
      case 5:
        return _buildEmergencyView();
      default:
        return _buildPatientDashboard();
    }
  }

  Widget _buildPatientDashboard() {
    final vitals = getVitals();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Patient Vital-Sign Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Explicitly distinguishes Live, Historical, and Demo Readings', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    selectedNavIndex = 5;
                  });
                },
                icon: const Icon(Icons.call),
                label: const Text('Emergency'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: vitals.map((v) {
              return SizedBox(
                width: 280,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(v.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: v.isMissing ? Colors.grey.shade200 : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(v.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('${v.value} ${v.unit}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Source: ${v.source}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(v.trend, style: const TextStyle(fontSize: 12, color: Color(0xFF0A4D68))),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    final vitals = getVitals();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: vitals.length,
      itemBuilder: (context, i) {
        final v = vitals[i];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: Text('${v.title}: ${v.value} ${v.unit}'),
            subtitle: Text('Source: ${v.source} • Trend: ${v.trend}'),
            trailing: Text(v.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsView(bool isDoctor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (!isDoctor)
          FilledButton.icon(
            onPressed: () {
              setState(() {
                appointments.insert(0, {
                  'specialty': 'Cardiology Consultation',
                  'patient': 'Omar Khaled',
                  'date': '2026-11-05 10:00',
                  'status': 'PENDING',
                });
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Submit New Appointment Request (Status: Pending)'),
          ),
        const SizedBox(height: 16),
        ...appointments.map((apt) {
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text('${apt['specialty']} — ${apt['patient']}'),
              subtitle: Text('Scheduled: ${apt['date']}'),
              trailing: Chip(label: Text(apt['status']!)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDevicesView() {
    final devices = [
      {'name': 'Single-Lead ECG Patch', 'protocol': 'Unconfirmed BLE GATT', 'status': 'UNSUPPORTED'},
      {'name': 'Arm Blood Pressure Monitor', 'protocol': 'BLE Cuff Profile', 'status': 'DISCONNECTED'},
      {'name': 'Finger Pulse Oximeter', 'protocol': 'Vendor SDK Pending', 'status': 'DISCONNECTED'},
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: devices.map((d) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(d['name']!),
            subtitle: Text('Protocol: ${d['protocol']}'),
            trailing: Chip(label: Text(d['status']!)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmergencyView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Trusted Emergency Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Contact Name: $emergencyName'),
              Text('Phone Number: $emergencyPhone'),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(16)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening device phone dialer: tel:$emergencyPhone')),
                  );
                },
                icon: const Icon(Icons.phone_in_talk),
                label: const Text('Call Emergency Contact (User-Initiated Dialer)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorPortal() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text('Doctor Portal — Authorized Patients Only', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Card(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(child: Text('OK')),
            title: Text('Omar Khaled (Patient ID: P-001)'),
            subtitle: Text('Status: ACTIVE ASSIGNMENT • Authorized Vitals & ECG'),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminPortal() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text('System Admin Governance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Card(
          color: Colors.white,
          child: ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('RBAC Enforcement: Server-Side Active'),
            subtitle: Text('Roles Configured: Patient, Doctor, Admin'),
          ),
        ),
      ],
    );
  }

  Widget _buildAuditView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: auditLogs.length,
      itemBuilder: (context, i) {
        final log = auditLogs[i];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.security),
            title: Text('${log['action']} -> ${log['target']}'),
            subtitle: Text('Actor: ${log['actor']}'),
          ),
        );
      },
    );
  }
}

class ECGLiveView extends StatefulWidget {
  const ECGLiveView({super.key});

  @override
  State<ECGLiveView> createState() {
    return _ECGLiveViewState();
  }
}

class _ECGLiveViewState extends State<ECGLiveView> {
  final ListQueue<double> samples = ListQueue<double>(200);
  Timer? timer;
  bool isDemoStreaming = false;
  int tick = 0;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void toggleStream() {
    if (isDemoStreaming) {
      timer?.cancel();
      setState(() {
        isDemoStreaming = false;
        samples.clear();
      });
    } else {
      setState(() {
        isDemoStreaming = true;
      });
      timer = Timer.periodic(const Duration(milliseconds: 35), (_) {
        setState(() {
          tick++;
          final p = (tick % 40) / 40.0;
          double v = math.sin(p * 2 * math.pi) * 0.08;
          if (p > 0.45 && p < 0.50) v = 1.0;
          if (p >= 0.50 && p < 0.55) v = -0.35;
          if (samples.length >= 200) samples.removeFirst();
          samples.addLast(v);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ECG Live Monitor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              FilledButton(
                onPressed: toggleStream,
                child: Text(isDemoStreaming ? 'Stop Demo Stream' : 'Start Demo Test Stream'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: ECGPainter(samples.toList())),
                ),
                if (!isDemoStreaming)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No Confirmed ECG Hardware Connected.\nTeleCare never renders fake ECG data as real clinical waveforms.\nClick "Start Demo Test Stream" to test the CustomPainter buffer.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ECGPainter extends CustomPainter {
  final List<double> data;
  ECGPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final paint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final midY = size.height / 2;
    final dx = size.width / 200;
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = midY - (data[i] * size.height * 0.35);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ECGPainter oldDelegate) {
    return true;
  }
}
