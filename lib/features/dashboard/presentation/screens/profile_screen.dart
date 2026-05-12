import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'user_posts_screen.dart';
import 'edit_profile_screen.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data to ensure we have the latest status (e.g. Event Creator)
    Future.microtask(
      () => ref.read(authNotifierProvider.notifier).refreshUser(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: authState.isLoading && user == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Image
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: user?.profileImageUrl != null
                          ? NetworkImage(user!.profileImageUrl!)
                          : const AssetImage(
                                  'assets/images/profile_placeholder.png',
                                )
                                as ImageProvider,
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Name
                  Text(
                    user?.name ?? 'Guest User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Details List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Date of birth',
                          user?.dob != null ? _formatDate(user!.dob!) : '-',
                        ),
                        _buildDetailRow('Email Address', user?.email ?? '-'),
                        _buildDetailRow(
                          'Mobile Number',
                          user?.mobile ?? '-',
                          isVerified: true,
                        ),
                        _buildDetailRow('Facebook ID', user?.facebookId ?? '-'),
                        _buildDetailRow(
                          'Instagram ID',
                          user?.instagramId ?? '-',
                        ),
                        _buildDetailRow('Country', user?.country ?? 'India'),
                        _buildDetailRow('State', user?.state ?? '-'),
                        _buildDetailRow('City', user?.district ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Your Posts Button (Conditional)
                  if (user?.isEventCreator ?? false)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserPostsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Your posts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.send, color: Colors.blue, size: 20),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Log Out Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: const Text(
                                'Log Out',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to log out?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(dialogContext).pop();
                                    try {
                                      await ref
                                          .read(authNotifierProvider.notifier)
                                          .signOut();
                                      if (context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SignInScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error logging out: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'log out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isVerified = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const Text(
            ' -  ',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    value.isEmpty ? '-' : value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVerified && value != '-' && value.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
