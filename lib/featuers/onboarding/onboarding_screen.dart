import 'package:flutter/material.dart';
import '../auth/register/presentation/register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final String? selectedRole;
  const OnboardingScreen({super.key, this.selectedRole});

  @override
  Widget build(BuildContext context) {
    return RegisterScreen(role: selectedRole);
  }
}
