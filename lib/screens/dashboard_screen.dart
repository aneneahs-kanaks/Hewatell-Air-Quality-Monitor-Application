import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_device_screen.dart';
import 'select_device_screen.dart';
import 'current_data_screen.dart';
import 'previous_data_screen.dart';



class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged Out Successfully.')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to HewaTell Dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 48),

              // ─── UPDATED REGISTER DEVICE MENU BUTTON ───
              _buildDashboardButton(
                label: 'Register New Device',
                icon: Icons.add_to_queue_outlined,
                onPressed: () {
                  // 2. Added the formal push navigator route to open your registration page!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterDeviceScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildDashboardButton(
                label: 'Select Existing Device',
                icon: Icons.devices_other_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectDeviceScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildDashboardButton(
                label: 'View Current Data',
                icon: Icons.bar_chart_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrentDataScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _buildDashboardButton(
                label: 'View Previous Data',
                icon: Icons.history_toggle_off_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreviousDataScreen(),
                    ),
                  );
                  // TODO: Attach your bulk historic cloud database data tracker records
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 3,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(icon, size: 24),
      label: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
