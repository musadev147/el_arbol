import 'package:flutter/material.dart';

class TenantWallet extends StatelessWidget {
  const TenantWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Your Wallet is empty.'),
      ),
    );
  }
}
