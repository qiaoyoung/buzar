import 'package:flutter/material.dart';
import 'package:buzar/screens/feedback_screen.dart';
import 'package:buzar/widgets/common_content_screen.dart';
import 'package:buzar/constants/app_contents.dart';
import 'package:buzar/screens/music_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help',
                  onTap: () => _navigateToContent(context, 'Help', AppContents.helpContent),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'User Agreement',
                  onTap: () => _navigateToContent(context, 'User Agreement', AppContents.userAgreement),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _navigateToContent(context, 'Privacy Policy', AppContents.privacyPolicy),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Feedback',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                  ),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.music_note,
                  title: 'Background Music',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MusicListScreen(),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () => _navigateToContent(context, 'About Us', AppContents.aboutUs),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.new_releases_outlined,
                  title: 'Version',
                  trailing: Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16);
  }

  void _navigateToContent(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommonContentScreen(
          title: title,
          content: content,
        ),
      ),
    );
  }
} 