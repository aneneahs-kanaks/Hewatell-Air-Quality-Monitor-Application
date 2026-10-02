import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterDeviceScreen extends StatefulWidget {
  const RegisterDeviceScreen({super.key});

  @override
  State<RegisterDeviceScreen> createState() => _RegisterDeviceScreenState();
}

class _RegisterDeviceScreenState extends State<RegisterDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers matching the exact field layout rows from your reference design image
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;

  // BACKEND: Core Logic to save the input form fields to Cloud Firestore database collections
  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Retrieve the unique authenticated User ID from the Firebase Auth vault
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('No authenticated user found.');

      // 2. Write the properties directly into the 'devices' collection in Firestore
      await FirebaseFirestore.instance.collection('devices').doc(_idController.text.trim()).set({
        'deviceName': _nameController.text.trim(),
        'deviceId': _idController.text.trim(),
        'location': _locationController.text.trim(),
        'ownerUid': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Success Alert Popup banner feedback feedback loop
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device registered successfully! 🎉')),
        );
        Navigator.pop(context); // Go back cleanly to the Dashboard screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Renders the clean navigation header bar with native back arrow button
        title: const Text(
          'Register New Device',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal, // Perfect color consistency with previous screens
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Title Headline matching structural layout alignment requirements
                const Text(
                  'Enter New Device',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal, // Locked to matching theme color accent selection
                  ),
                ),
                const SizedBox(height: 36),

                // ─── FIELD 1: DEVICE NAME ───
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal, width: 2)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please fill out this field.' : null,
                ),
                const SizedBox(height: 24),

                // ─── FIELD 2: DEVICE ID ───
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'Device ID',
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal, width: 2)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please fill out this field.' : null,
                ),
                const SizedBox(height: 24),

                // ─── FIELD 3: LOCATION ───
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal, width: 2)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please fill out this field.' : null,
                ),
                const SizedBox(height: 54),

                // ─── ACTION SUBMIT CONTROL BUTTON PANEL ───
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Perfect theme synchronization palette matching selection
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _submitRegistration,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'Register Device',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
