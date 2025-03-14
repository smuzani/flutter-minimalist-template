import 'package:flutter/material.dart';

/// A widget that wraps content and provides network connectivity feedback
class NetworkAwareView extends StatelessWidget {
  final Widget child;
  final Widget? offlineChild;
  final bool isOnline;
  final VoidCallback onRetry;

  const NetworkAwareView({
    Key? key,
    required this.child,
    this.offlineChild,
    required this.isOnline,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return Stack(
        children: [
          child,
          // Show a banner if we're using mock data
          if (!isOnline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildOfflineBanner(context),
            ),
        ],
      );
    }

    return offlineChild ?? _buildDefaultOfflineView(context);
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      color: Colors.orange.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Text(
            'Offline Mode - Using local data',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultOfflineView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'You are currently offline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your connection and try again',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
} 