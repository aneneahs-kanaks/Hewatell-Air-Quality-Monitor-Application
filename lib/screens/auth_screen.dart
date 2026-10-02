import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // 1. Added Import Package

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 2. BACKEND: Cleaned Google Authentication Handler for package v7.x
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Initialize the singleton instance securely
      await GoogleSignIn.instance.initialize();

      // Trigger the local phone's native Google account sheet picker prompt
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User explicitly cancelled out of the menu popup
      }

      // Obtain authentication tokens safely from the verified account data
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a secure validation credential for Firebase Auth using the ID Token
      // (The accessToken parameter is no longer required or present in v7.x!)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Authenticate cleanly with the cloud engine using the credential
      await FirebaseAuth.instance.signInWithCredential(credential);
      _showSnackBar('Welcome to Hewatell via Google! 🍃');
    } catch (e) {
      _showSnackBar('Google Sign-In Failed: $e');
    } finally { // Fixed spelling here: changed from finaly to finally!
      setState(() => _isLoading = false);
    }
  }



  // Backend: Normal Email/Password Execution Handler
  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isSignIn) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showSnackBar('Welcome Back to Hewatell! 🎉');
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showSnackBar('Account Created Successfully! 🚀');
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'An error occurred.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.air, size: 90, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to Hewatell',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const Text(
                  'Air Quality Monitor',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 40),

                Text(
                  _isSignIn ? 'Account Sign In' : 'Create New Account',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Please enter a valid email.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters.' : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _isLoading ? null : _submitAuthForm,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isSignIn ? 'Sign In' : 'Sign Up'),
                ),
                const SizedBox(height: 16),

                // 3. FRONTEND: Divider Visual Ornament Line
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.all(8.0), child: Text("OR", style: TextStyle(color: Colors.grey))),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. FRONTEND: The Interactive Google Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.grey)),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 30, color: Colors.red),
                  label: const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontSize: 16)),
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => setState(() => _isSignIn = !_isSignIn),
                  child: Text(
                    _isSignIn ? "Don't have an account? Sign Up here" : 'Already have an account? Sign In here',
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
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
