import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/opportunity_provider.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class OpportunityDetailsScreen extends StatefulWidget {
  final int opportunityId;

  const OpportunityDetailsScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  State<OpportunityDetailsScreen> createState() =>
      _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState extends State<OpportunityDetailsScreen> {
  bool _isApplying = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final opportunityProvider =
        Provider.of<OpportunityProvider>(context, listen: false);
    final success = await opportunityProvider.getOpportunityDetails(widget.opportunityId);

    if (success) {
      final applicationProvider =
          Provider.of<ApplicationProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.isLoggedIn) {
        await applicationProvider.loadUserApplications(authProvider.currentUser!.id);
        setState(() {
          _hasApplied = applicationProvider.hasAppliedToOpportunity(widget.opportunityId);
        });
      }
    }
  }

  Future<void> _apply() async {
    if (_isApplying) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final applicationProvider =
        Provider.of<ApplicationProvider>(context, listen: false);

    setState(() {
      _isApplying = true;
    });

    final success = await applicationProvider.applyForOpportunity(
      authProvider.currentUser!.id,
      widget.opportunityId,
    );

    setState(() {
      _isApplying = false;
    });

    if (!mounted) return;

    if (success) {
      setState(() {
        _hasApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(applicationProvider.error ?? 'Failed to apply'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final opportunityProvider = Provider.of<OpportunityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: opportunityProvider.isLoading
          ? const LoadingWidget()
          : opportunityProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        opportunityProvider.error!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final opportunity = Provider.of<OpportunityProvider>(context).selectedOpportunity!;
    final authProvider = Provider.of<AuthProvider>(context);
    final isVolunteer = authProvider.isVolunteer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  opportunity.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${opportunity.ngoName}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            opportunity.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.location_on, 'Location', opportunity.location),
          _buildDetailRow(Icons.calendar_today, 'Date', 
              DateFormat('MMM dd, yyyy').format(DateTime.parse(opportunity.date))),
          _buildDetailRow(Icons.access_time, 'Time', opportunity.time),
          _buildDetailRow(Icons.people, 'Volunteers Required', 
              '${opportunity.volunteersRequired}'),
          if (opportunity.latitude != null && opportunity.longitude != null) ...[
  const SizedBox(height: 12),
  Container(
    height: 60,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.location_on, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '📍 ${opportunity.latitude}, ${opportunity.longitude}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  ),
],
          const SizedBox(height: 24),
          if (isVolunteer)
            SizedBox(
              width: double.infinity,
              child: _hasApplied
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'You have already applied for this opportunity',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _isApplying ? null : _apply,
                      child: _isApplying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('APPLY NOW'),
                    ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}