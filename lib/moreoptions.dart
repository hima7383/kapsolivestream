import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  final String imageAssetPath = 'images/iconlogo1.png'; // Make sure this path is correct

  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Example: Pop the current screen
          },
        ),
        title: const Text(
          'More',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // <--- Wrap the Column with SingleChildScrollView here --->
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Image.asset(
                imageAssetPath,
                height: 120, // Adjust size as needed
                width: 120, // Adjust size as needed
              ),
            ),
            const Divider(color: Colors.red, thickness: 1.0),
            _buildMoreListItem(
              context,
              'Terms Of Service',
              Icons.arrow_back_ios,
              Icons.description,
              onTap: () {
                // Handle tap
              },
            ),
            const Divider(color: Colors.red, thickness: 1.0),
            _buildMoreListItem(
              context,
              'Privacy Policy',
              Icons.arrow_back_ios,
              Icons.policy,
              onTap: () {
                // Handle tap
              },
            ),
            const Divider(color: Colors.red, thickness: 1.0),
            _buildMoreListItem(
              context,
              'About Us',
              Icons.arrow_back_ios,
              Icons.info_outline,
              onTap: () {
                // Handle tap
              },
            ),
            const Divider(color: Colors.red, thickness: 1.0),
            _buildMoreListItem(
              context,
              'Share Profile',
              Icons.arrow_back_ios,
              Icons.share,
              onTap: () {
                // Handle tap
              },
            ),
            const Divider(color: Colors.red, thickness: 1.0),
            _buildMoreListItem(
              context,
              'Report',
              Icons.arrow_back_ios,
              Icons.do_not_disturb_on,
              onTap: () {
                // Handle tap
              },
            ),
            const Divider(color: Colors.red, thickness: 1.0),
            _buildMoreListItem(
              context,
              'Block',
              Icons.arrow_back_ios,
              Icons.block,
              onTap: () {
                // Handle tap
              },
            ),
            const Divider(color: Colors.red, thickness: 1.0),
            _buildMoreListItem(
              context,
              'Log Out',
              Icons.arrow_back_ios,
              Icons.logout,
              onTap: () {
                // Handle tap
              },
            ),
            const Divider(color: Colors.red, thickness: 1.0),
            // The Spacer() won't work correctly inside SingleChildScrollView
            // as it tries to take up infinite space. Replace it with SizedBox for spacing.
            SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Adjust as needed
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                'KABSO | 2025®',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10), // Add padding for bottom safe area
          ],
        ),
      ),
      // <--- End of SingleChildScrollView wrap --->
    );
  }

  Widget _buildMoreListItem(
      BuildContext context, String title, IconData leadingIcon, IconData trailingIcon,
      {VoidCallback? onTap}) {
    return ListTile(
      tileColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Transform.rotate(
        angle: 0,
        child: Icon(leadingIcon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      trailing: Icon(trailingIcon, color: Colors.red, size: 24),
      onTap: onTap,
    );
  }
}