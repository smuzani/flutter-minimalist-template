import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../viewmodels/user_view_model.dart';
import 'user_detail_view.dart';
import 'network_aware_view.dart';

// Provider to track if we're showing mock data
final isMockDataProvider = StateProvider<bool>((ref) => false);

class UserListView extends ConsumerWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersProvider);
    final isMockData = ref.watch(isMockDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(usersProvider.notifier).refreshUsers();
            },
          ),
        ],
      ),
      body: usersState.when(
        data: (users) => _buildUserListWithNetwork(context, ref, users, true),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          // On error, update the mock data state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(isMockDataProvider.notifier).state = true;
          });
          
          return _buildErrorView(context, ref, error.toString());
        }
      ),
    );
  }

  Widget _buildUserListWithNetwork(
    BuildContext context, 
    WidgetRef ref, 
    List<UserModel> users, 
    bool isOnline
  ) {
    return NetworkAwareView(
      isOnline: !ref.watch(isMockDataProvider), // If using mock data, then we're "offline"
      onRetry: () {
        ref.read(isMockDataProvider.notifier).state = false;
        ref.read(usersProvider.notifier).refreshUsers();
      },
      child: _buildUserList(context, ref, users),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Unable to connect to the server',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll show you some sample data instead.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Error: $errorMessage',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(usersProvider.notifier).loadUsers();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, WidgetRef ref, List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }
    
    return RefreshIndicator(
      onRefresh: () => ref.read(usersProvider.notifier).refreshUsers(),
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserListItem(context, ref, user, index);
        },
      ),
    );
  }

  Widget _buildUserListItem(BuildContext context, WidgetRef ref, UserModel user, int index) {
    // Using index in tag to ensure uniqueness
    final heroTag = 'user-avatar-${user.uuid}-$index';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Hero(
          tag: heroTag,
          child: CircleAvatar(
            backgroundImage: NetworkImage(user.thumbnailUrl),
            radius: 25,
            onBackgroundImageError: (_, __) {
              // Handle image load error
            },
            child: NetworkImage(user.thumbnailUrl).toString().contains('placeholder') 
                ? const Icon(Icons.person, size: 25) 
                : null,
          ),
        ),
        title: Text(user.fullName),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // First select the user
          ref.read(selectedUserProvider.notifier).selectUser(user.uuid);
          
          // Then navigate to detail view
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailView(heroTag: heroTag),
            ),
          );
        },
      ),
    );
  }
} 