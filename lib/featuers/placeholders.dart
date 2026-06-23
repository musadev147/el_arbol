import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            '$title Screen\n(Coming Soon)',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class MyPropertyScreen extends StatelessWidget {
  const MyPropertyScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'My Property');
}

class LandlordHomeScreen extends StatelessWidget {
  const LandlordHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Landlord Home');
}

class MessagesLandlordScreen extends StatelessWidget {
  const MessagesLandlordScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Landlord Messages');
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Landlord Wallet');
}

class LandlordMyPropertyScreen extends StatelessWidget {
  const LandlordMyPropertyScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Landlord My Property');
}

class LandlordProfileScreen extends StatelessWidget {
  const LandlordProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Landlord Profile');
}

class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Agent Home');
}

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Agent Profile');
}

class WorkmanHomeScreen extends StatelessWidget {
  const WorkmanHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Workman Home');
}

class WorkmanJobsPendingScreen extends StatelessWidget {
  const WorkmanJobsPendingScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Workman Pending Jobs');
}

class WorkmenProfileScreen extends StatelessWidget {
  const WorkmenProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Workmen Profile');
}

class PropertySearchScreen extends StatelessWidget {
  const PropertySearchScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Property Search');
}

class MyAppsScreen extends StatelessWidget {
  final String pdfPath;
  final int astId;
  final int propertyId;

  const MyAppsScreen({
    super.key,
    required this.pdfPath,
    required this.astId,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'My Apps (PDF Signed: $pdfPath)');
}

class AddNewPropertyStep1 extends StatelessWidget {
  final int propertyId;
  final bool isEdit;

  const AddNewPropertyStep1({
    super.key,
    required this.propertyId,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'Add New Property Step 1 (ID: $propertyId, Edit: $isEdit)');
}

class CreateNewTenantScreen extends StatelessWidget {
  final int initialTab;

  const CreateNewTenantScreen({
    super.key,
    required this.initialTab,
  });

  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'Create New Tenant (Tab: $initialTab)');
}

class PreviewLandlordUploadScreen extends StatelessWidget {
  final String pdfPath;
  final int propertyId;
  final int tenancyId;
  final int astId;

  const PreviewLandlordUploadScreen({
    super.key,
    required this.pdfPath,
    required this.propertyId,
    required this.tenancyId,
    required this.astId,
  });

  @override
  Widget build(BuildContext context) => PlaceholderScreen(
        title: 'Preview Landlord Upload (PDF: $pdfPath, Prop: $propertyId, Tenancy: $tenancyId, AST: $astId)',
      );
}
