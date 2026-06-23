import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final int points;
  const ProfileScreen({super.key, this.points = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text('Profile details. Points: $points'),
      ),
    );
  }
}
