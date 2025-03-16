import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nilean/ui/widgets/app_buttons.dart';
import 'package:nilean/ui/widgets/app_texts.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _profilePictureUrl;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppButtons.backButton(onPressed: () {}),
              const SizedBox(height: 20),
              AppTexts.sectionTitle(
                title: 'My Account',
                subtitle: '',
                context: context,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    _profilePictureUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(_profilePictureUrl!),
                            radius: 50,
                          )
                        : CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 100),
                          ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickProfilePicture,
                      child: Text('Update Profile Picture'),
                    ),
                    SizedBox(height: 20),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Update Button
                    ElevatedButton(
                      onPressed: _updateAccount,
                      child: Text('Update Account'),
                    ),
                    SizedBox(height: 20),

                    // Delete Account Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _deleteAccount,
                      child: Text('Delete Account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (photo != null) {
        _pickedImage = photo;
      } else {
        _pickedImage = null;
      }
    });
    await _uploadProfilePicture();
  }

  Future<void> _uploadProfilePicture() async {
    if (_pickedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profilePictures/${FirebaseAuth.instance.currentUser?.uid}');
      await ref.putFile(File(_pickedImage!.path));
      final url = await ref.getDownloadURL();
      setState(() {
        _profilePictureUrl = url;
      });
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);
    }
  }

  void _updateAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.currentUser
            ?.updateDisplayName(_nameController.text);
        if (_passwordController.text.isNotEmpty) {
          await FirebaseAuth.instance.currentUser
              ?.updatePassword(_passwordController.text);
        }
        if (_pickedImage != null) {
          await _uploadProfilePicture();
        }
        snackBar('Account updated successfully');
      } catch (e) {
        snackBar('Error updating account: $e');
      }
    }
  }

  void _deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      snackBar('Account deleted successfully');
    } catch (e) {
      snackBar('Error deleting account: $e');
    }
  }

  snackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
