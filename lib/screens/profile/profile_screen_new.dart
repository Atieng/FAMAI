import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:famai/services/firebase_service.dart';
import 'package:famai/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  
  User? get _currentUser => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _createUserDocIfNeeded();
  }
  
  Future<void> _createUserDocIfNeeded() async {
    if (_currentUser == null) return;
    
    try {
      final userRef = _firestore.collection('users').doc(_currentUser!.uid);
      final docSnapshot = await userRef.get();
      
      if (!docSnapshot.exists) {
        await userRef.set({
          'name': _currentUser!.displayName ?? 'User',
          'email': _currentUser!.email ?? 'No email',
          'createdAt': DateTime.now().toString(),
        });
      }
    } catch (e) {
      debugPrint('Error creating user document: $e');
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_currentUser == null) return;
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      
      if (image == null) return;
      
      setState(() {
        _isUploading = true;
      });
      
      // Upload to Firebase Storage
      final File imageFile = File(image.path);
      final ref = FirebaseStorage.instance.ref()
          .child('profile_pictures')
          .child('${_currentUser!.uid}.jpg');
          
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      // Save URL to Firestore
      await _firestore.collection('users').doc(_currentUser!.uid).set({
        'profile_picture': downloadUrl,
      }, SetOptions(merge: true));
      
      setState(() {
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading picture: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Not logged in')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(_currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(userData),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Account'),
                  _buildProfileCard([
                    _buildListTile(Icons.person, 'Name', userData['name'] ?? 'User'),
                    _buildListTile(Icons.email, 'Email', userData['email'] ?? 'No email'),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('App'),
                  _buildProfileCard([
                    _buildListTile(Icons.info, 'About Famai', 'Version 1.0.0'),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Appearance'),
                  _buildProfileCard([
                    ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: const Text('Theme'),
                      trailing: DropdownButton<ThemeMode>(
                        value: themeProvider.themeMode,
                        items: const [
                          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setTheme(value);
                          }
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      await _firebaseService.signOut();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Sign Out'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    final profilePictureUrl = userData['profile_picture'] as String?;
    
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: profilePictureUrl != null ? NetworkImage(profilePictureUrl) : null,
              child: profilePictureUrl == null
                  ? Text(_getInitials(userData['name'] ?? 'User'), 
                      style: Theme.of(context).textTheme.headlineLarge)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: _isUploading 
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _uploadProfilePicture,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(userData['name'] ?? 'User', 
             style: Theme.of(context).textTheme.headlineSmall),
        Text(userData['email'] ?? 'No email', 
             style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
  
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
