import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/opportunity_provider.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_widget.dart';
import '../utils/validators.dart';
import '../models/opportunity.dart';
import 'login_screen.dart';
import 'map_picker_screen.dart';
import 'package:intl/intl.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final opportunityProvider =
        Provider.of<OpportunityProvider>(context, listen: false);

    await opportunityProvider.loadOpportunities(
      role: authProvider.currentUser?.role,
      email: authProvider.currentUser?.email,
    );
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _showAddOpportunityDialog({Opportunity? opportunity}) async {
    final isEditing = opportunity != null;
    final formKey = GlobalKey<FormState>();
    final titleController =
        TextEditingController(text: opportunity?.title ?? '');
    final descriptionController =
        TextEditingController(text: opportunity?.description ?? '');
    final ngoNameController =
        TextEditingController(text: opportunity?.ngoName ?? '');
    String category = opportunity?.category ?? 'Education';
    final locationController =
        TextEditingController(text: opportunity?.location ?? '');
    final latitudeController =
        TextEditingController(text: opportunity?.latitude?.toString() ?? '');
    final longitudeController =
        TextEditingController(text: opportunity?.longitude?.toString() ?? '');
    final dateController = TextEditingController(text: opportunity?.date ?? '');
    final timeController = TextEditingController(text: opportunity?.time ?? '');
    final volunteersController = TextEditingController(
        text: opportunity?.volunteersRequired.toString() ?? '');
    bool isLoading = false;

    final categories = [
      'Education',
      'Environment',
      'Health',
      'Community',
      'Animal Welfare',
      'Social Service'
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEditing ? 'Edit Opportunity' : 'Add New Opportunity',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                          labelText: 'Title', prefixIcon: Icon(Icons.title)),
                      validator: (value) =>
                          Validators.requiredValidator(value, field: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description)),
                      maxLines: 3,
                      validator: (value) => Validators.requiredValidator(value,
                          field: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ngoNameController,
                      decoration: const InputDecoration(
                          labelText: 'NGO Name',
                          prefixIcon: Icon(Icons.business)),
                      validator: (value) => Validators.requiredValidator(value,
                          field: 'NGO Name'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category)),
                      items: categories
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          category = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // LOCATION PICKER (Google Map se)
                    TextFormField(
                      controller: locationController,
                      readOnly: true,
                      onTap: () async {
                        // Yahan Map<String, double?> use karo
                        final Map<String, double?>? pickedLocation =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LocationPickerScreen()),
                        );
                        if (pickedLocation != null) {
                          setState(() {
                            locationController.text = 'Picked Location';
                            latitudeController.text =
                                pickedLocation['latitude']?.toString() ?? '';
                            longitudeController.text =
                                pickedLocation['longitude']?.toString() ?? '';
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Location (Tap to pick)',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) => Validators.requiredValidator(value,
                          field: 'Location'),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              prefixIcon: Icon(Icons.pin_drop),
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true, // GPS se aayega
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              prefixIcon: Icon(Icons.pin_drop),
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true, // GPS se aayega
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // DATE PICKER
                    TextFormField(
                      controller: dateController,
                      readOnly: true, // Manually type nahi kar sakte
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) =>
                          Validators.requiredValidator(value, field: 'Date'),
                    ),
                    const SizedBox(height: 12),

                    // TIME PICKER
                    TextFormField(
                      controller: timeController,
                      readOnly: true, // Manually type nahi kar sakte
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            // Time ko format karo (e.g., 09:00 AM)
                            final now = DateTime.now();
                            final dt = DateTime(now.year, now.month, now.day,
                                pickedTime.hour, pickedTime.minute);
                            timeController.text =
                                DateFormat('hh:mm a').format(dt);
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) =>
                          Validators.requiredValidator(value, field: 'Time'),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: volunteersController,
                      decoration: const InputDecoration(
                          labelText: 'Volunteers Required',
                          prefixIcon: Icon(Icons.people)),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.requiredValidator(value,
                          field: 'Volunteers Required'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setState(() => isLoading = true);

                              final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false);
                              final opportunityProvider =
                                  Provider.of<OpportunityProvider>(context,
                                      listen: false);

                              final data = {
                                'title': titleController.text.trim(),
                                'description':
                                    descriptionController.text.trim(),
                                'ngo_name': ngoNameController.text.trim(),
                                'category': category,
                                'location': locationController.text.trim(),
                                'latitude': double.tryParse(
                                    latitudeController.text.trim()),
                                'longitude': double.tryParse(
                                    longitudeController.text.trim()),
                                'date': dateController.text.trim(),
                                'time': timeController.text.trim(),
                                'volunteers_required': int.tryParse(
                                        volunteersController.text.trim()) ??
                                    0,
                                'role': authProvider.currentUser!.role,
                                'email': authProvider.currentUser!.email,
                              };

                              bool success;
                              if (isEditing) {
                                success = await opportunityProvider
                                    .updateOpportunity(opportunity!.id, data);
                              } else {
                                success = await opportunityProvider
                                    .createOpportunity(data);
                              }

                              setState(() => isLoading = false);
                              if (!context.mounted) return;

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEditing
                                        ? 'Opportunity updated successfully'
                                        : 'Opportunity created successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                await _loadData();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(opportunityProvider.error ??
                                          'Operation failed'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'UPDATE' : 'SAVE'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showApplicantsDialog(int opportunityId, String title) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final applicationProvider =
        Provider.of<ApplicationProvider>(context, listen: false);

    await applicationProvider.loadApplicants(
        opportunityId, authProvider.currentUser!.role,
        email: authProvider.currentUser!.email);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Applicants for $title'),
            content: applicationProvider.isLoading
                ? const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()))
                : applicationProvider.applicants.isEmpty
                    ? const SizedBox(
                        height: 100,
                        child: Center(child: Text('No applicants yet')))
                    : SizedBox(
                        width: double.maxFinite,
                        height: 400,
                        child: ListView.builder(
                          itemCount: applicationProvider.applicants.length,
                          itemBuilder: (context, index) {
                            final applicant =
                                applicationProvider.applicants[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(applicant.volunteerName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                    applicant.status)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(applicant.status,
                                              style: TextStyle(
                                                  color: _getStatusColor(
                                                      applicant.status),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('📧 ${applicant.email}'),
                                    Text('📱 ${applicant.phone}'),
                                    Text(
                                        'Applied: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(applicant.appliedDate))}',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 4,
                                      children: ['Approved', 'Rejected']
                                          .map((status) {
                                        final isSelected =
                                            applicant.status == status;
                                        return GestureDetector(
                                          onTap: () async {
                                            if (isSelected) return;
                                            final authProvider =
                                                Provider.of<AuthProvider>(
                                                    context,
                                                    listen: false);
                                            final applicationProvider = Provider
                                                .of<ApplicationProvider>(
                                                    context,
                                                    listen: false);
                                            final success =
                                                await applicationProvider
                                                    .updateApplicationStatus(
                                              applicant.applicationId,
                                              status,
                                              authProvider.currentUser!.role,
                                              email: authProvider
                                                  .currentUser!.email,
                                            );
                                            if (!context.mounted) return;
                                            if (success) {
                                              await applicationProvider
                                                  .loadApplicants(
                                                      opportunityId,
                                                      authProvider
                                                          .currentUser!.role,
                                                      email: authProvider
                                                          .currentUser!.email);
                                              setState(() {});
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content:
                                                        Text('Status updated'),
                                                    backgroundColor:
                                                        Colors.green),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        applicationProvider
                                                                .error ??
                                                            'Failed to update'),
                                                    backgroundColor:
                                                        Colors.red),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? _getStatusColor(status)
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(status,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                )),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            actions: [
              TextButton(
                onPressed: () {
                  applicationProvider.clearApplicants();
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Cancelled':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final opportunityProvider = Provider.of<OpportunityProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('NGO Dashboard (${authProvider.currentUser?.name ?? ''})'),
        backgroundColor: const Color(0xFF00695C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            opportunityProvider.opportunities.length.toString(),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal)),
                        const Text('My Opportunities',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('0',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const Text('My Applications',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Opportunities',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddOpportunityDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: opportunityProvider.isLoading
                ? const LoadingWidget()
                : opportunityProvider.opportunities.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_box, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text('No opportunities created yet',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: opportunityProvider.opportunities.length,
                        itemBuilder: (context, index) {
                          final opp = opportunityProvider.opportunities[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(opp.title,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(opp.category,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('by ${opp.ngoName}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(opp.location,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13)),
                                      const SizedBox(width: 12),
                                      Icon(Icons.calendar_today,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, yyyy')
                                            .format(DateTime.parse(opp.date)),
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _showAddOpportunityDialog(
                                                  opportunity: opp),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            side: const BorderSide(
                                                color: Colors.blue),
                                          ),
                                          icon:
                                              const Icon(Icons.edit, size: 16),
                                          label: const Text('Edit'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Delete Opportunity'),
                                                content: const Text(
                                                    'Are you sure you want to delete this opportunity?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Cancel')),
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red))),
                                                ],
                                              ),
                                            );
                                            if (confirm != true) return;
                                            final success =
                                                await opportunityProvider
                                                    .deleteOpportunity(
                                                        opp.id,
                                                        authProvider
                                                            .currentUser!.role,
                                                        email: authProvider
                                                            .currentUser!
                                                            .email);
                                            if (!mounted) return;
                                            if (success) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Opportunity deleted'),
                                                    backgroundColor:
                                                        Colors.green),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        opportunityProvider
                                                                .error ??
                                                            'Delete failed'),
                                                    backgroundColor:
                                                        Colors.red),
                                              );
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            side: const BorderSide(
                                                color: Colors.red),
                                          ),
                                          icon: const Icon(Icons.delete,
                                              size: 16, color: Colors.red),
                                          label: const Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showApplicantsDialog(
                                          opp.id, opp.title),
                                      style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8)),
                                      icon: const Icon(Icons.people, size: 16),
                                      label: const Text('View Applicants'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
