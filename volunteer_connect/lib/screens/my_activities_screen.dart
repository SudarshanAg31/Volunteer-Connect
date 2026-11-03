import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/application_card.dart';
import '../widgets/loading_widget.dart';

class MyActivitiesScreen extends StatefulWidget {
  const MyActivitiesScreen({super.key});

  @override
  State<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen> {
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    // ✅ Delayed load to avoid build errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final applicationProvider =
        Provider.of<ApplicationProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      print('🔄 Loading activities for user: ${authProvider.currentUser!.id}');
      
      // ✅ Refresh flag
      if (mounted) {
        setState(() {
          _initialLoadDone = true;
        });
      }
      
      await applicationProvider.loadUserApplications(authProvider.currentUser!.id);
    }
  }

  Future<void> _cancelApplication(int applicationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Application'),
        content: const Text(
          'Are you sure you want to cancel this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    final applicationProvider =
        Provider.of<ApplicationProvider>(context, listen: false);
    final success =
      await applicationProvider.cancelApplication(applicationId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(applicationProvider.error ?? 'Failed to cancel'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationProvider = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activities'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          // ✅ Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: applicationProvider.isLoading ? null : _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(applicationProvider),
      ),
    );
  }

  Widget _buildBody(ApplicationProvider provider) {
    // ✅ Loading state
    if (provider.isLoading && provider.applications.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading activities...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // ✅ Error state
    if (provider.error != null) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ✅ Empty state
    if (provider.applications.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No activities yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apply to opportunities to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // ✅ Data state
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.applications.length,
      itemBuilder: (context, index) {
        final application = provider.applications[index];
        final isCancellable =
            application.status == 'Applied' ||
            application.status == 'Approved';
        return ApplicationCard(
          application: application,
          showCancelButton: isCancellable,
          onCancel: () => _cancelApplication(application.applicationId),
        );
      },
    );
  }
}