import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/opportunity_provider.dart';
import '../providers/application_provider.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/loading_widget.dart';
import 'opportunity_details_screen.dart';
import 'my_activities_screen.dart';
import 'profile_screen.dart';

class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final opportunityProvider = Provider.of<OpportunityProvider>(context, listen: false);
    await opportunityProvider.loadOpportunities();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      final applicationProvider = Provider.of<ApplicationProvider>(context, listen: false);
      await applicationProvider.loadUserApplications(authProvider.currentUser!.id);
    }
  }

  void _onSearchChanged(String query) {
    final opportunityProvider = Provider.of<OpportunityProvider>(context, listen: false);
    opportunityProvider.loadOpportunities(
      search: query.trim().isEmpty ? null : query.trim(),
      category: opportunityProvider.selectedCategory,
    );
  }

  void _onCategorySelected(String category) {
    final opportunityProvider = Provider.of<OpportunityProvider>(context, listen: false);
    opportunityProvider.loadOpportunities(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      category: category == 'All' ? null : category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? _buildHomeContent()
          : _currentIndex == 1
              ? const MyActivitiesScreen()
              : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.isLoggedIn) {
              final applicationProvider = Provider.of<ApplicationProvider>(context, listen: false);
              applicationProvider.loadUserApplications(authProvider.currentUser!.id);
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildHomeContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final opportunityProvider = Provider.of<OpportunityProvider>(context);
    final applicationProvider = Provider.of<ApplicationProvider>(context);

    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Hello, ${authProvider.currentUser?.name ?? 'Volunteer'} 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Find opportunities to make a difference.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search opportunities...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: opportunityProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = opportunityProvider.categories[index];
                  final isSelected = opportunityProvider.selectedCategory == category ||
                      (opportunityProvider.selectedCategory == null && category == 'All');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => _onCategorySelected(category),
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (opportunityProvider.isLoading)
              const LoadingWidget()
            else if (opportunityProvider.error != null)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      opportunityProvider.error!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (opportunityProvider.opportunities.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No opportunities found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: opportunityProvider.opportunities.length,
                itemBuilder: (context, index) {
                  final opportunity = opportunityProvider.opportunities[index];
                  final hasApplied = applicationProvider.hasAppliedToOpportunity(opportunity.id);
                  return OpportunityCard(
                    opportunity: opportunity,
                    hasApplied: hasApplied,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OpportunityDetailsScreen(
                            opportunityId: opportunity.id,
                          ),
                        ),
                      ).then((_) => _loadData());
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}