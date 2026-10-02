import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectDeviceScreen extends StatefulWidget {
  const SelectDeviceScreen({super.key});

  @override
  State<SelectDeviceScreen> createState() => _SelectDeviceScreenState();
}

class _SelectDeviceScreenState extends State<SelectDeviceScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Keep track of the currently logged-in user's unique ID
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Select Existing Device',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── FRONTEND: SEARCH INTERFACE BLOCK ───
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'search device by name...', // Matching your exact text request
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // ─── BACKEND: REAL-TIME FIRESTORE DEVICE FETCH PIPELINE ───
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Query only devices owned by the active logged-in user
                stream: FirebaseFirestore.instance
                    .collection('devices')
                    .where('ownerUid', isEqualTo: _currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  // 1. Connection Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.teal));
                  }

                  // 2. Error State Handler
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading devices: ${snapshot.error}'));
                  }

                  // 3. Grab the list of raw documents from the cloud snapshot
                  final documents = snapshot.data?.docs ?? [];

                  // Filter documents locally based on the search query input
                  final filteredDocs = documents.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['deviceName'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

                  // 4. Empty State Handler (No devices registered yet)
                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices_other, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No registered devices found.'
                                : 'No devices match your search.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  // 5. Active List Display Builder
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final deviceData = filteredDocs[index].data() as Map<String, dynamic>;
                      final deviceName = deviceData['deviceName'] ?? 'Unknown Device';
                      final deviceId = deviceData['deviceId'] ?? 'No ID';
                      final location = deviceData['location'] ?? 'Not Specified';

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            child: Icon(Icons.developer_board),
                          ),
                          title: Text(
                            deviceName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text('ID: $deviceId • Location: $location', style: const TextStyle(fontSize: 13)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                          onTap: () {
                            // Feedback toast confirming selection
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected: $deviceName ($deviceId)')),
                            );
                            Navigator.pop(context); // Go back to dashboard with the selection active
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
