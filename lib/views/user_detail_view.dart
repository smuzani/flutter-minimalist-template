import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/user_view_model.dart';
import '../models/user_model.dart';

class UserDetailView extends ConsumerWidget {
  final String? heroTag;
  
  const UserDetailView({Key? key, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(selectedUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: userState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user selected'));
          }
          return _buildUserDetails(context, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load user details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${error.toString()}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Hero(
              tag: 'user-avatar-${user.uuid}',
              child: CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(user.pictureUrl),
                onBackgroundImageError: (_, __) {
                  // Handle image load error silently
                },
                child: user.pictureUrl.contains('placeholder') 
                    ? const Icon(Icons.person, size: 80) 
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Personal Information',
            children: [
              _buildInfoRow('Name', user.fullName),
              _buildInfoRow('Gender', user.gender.toUpperCase()),
              _buildInfoRow('Date of Birth', _formatDate(user.dateOfBirth)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Contact Information',
            children: [
              _buildInfoRow('Email', user.email),
              _buildInfoRow('Phone', user.phone),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Address',
            children: [
              _buildInfoRow('Street', '${user.streetNumber} ${user.streetName}'),
              _buildInfoRow('City', user.city),
              _buildInfoRow('Postcode', user.postcode),
              _buildInfoRow('Country', user.country),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 