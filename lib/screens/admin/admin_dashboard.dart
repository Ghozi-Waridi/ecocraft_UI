import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../services/reward_service.dart';
import '../../utils/constants.dart';
import '../../widgets/user_stats_card.dart';
import 'user_management_screen.dart';
import 'reward_management_screen.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final UserService _userService = UserService();
  final RewardService _rewardService = RewardService();
  
  int _selectedIndex = 0;
  int _totalUsers = 0;
  int _totalBottles = 0;
  int _totalRewards = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    final users = await _userService.getTotalUsersCount();
    final bottles = await _userService.getTotalBottlesCollected();
    final rewards = await _rewardService.getTotalRewardsCount();
    
    setState(() {
      _totalUsers = users;
      _totalBottles = bottles;
      _totalRewards = rewards;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      _buildHomeScreen(user),
      const UserManagementScreen(),
      const RewardManagementScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'User Management';
      case 2:
        return 'Reward Management';
      default:
        return 'Admin';
    }
  }

  Widget _buildHomeScreen(user) {
    final isMobile = Breakpoints.isMobile(context);

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Selamat Datang, Admin! 👨‍💼',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Kelola sistem EcoCraft dengan mudah',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Stats Cards
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.paddingXLarge),
                  child: CircularProgressIndicator(),
                ),
              )
            else
            // Stats Cards
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.paddingXLarge),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (isMobile)
              Column(
                children: [
                  UserStatsCard(
                    title: 'Total Users',
                    value: '$_totalUsers',
                    icon: Icons.people,
                    color: AppColors.primary,
                    subtitle: 'Pengguna terdaftar',
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  UserStatsCard(
                    title: 'Total Botol',
                    value: '$_totalBottles',
                    icon: Icons.recycling,
                    color: AppColors.success,
                    subtitle: 'Botol terkumpul',
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  UserStatsCard(
                    title: 'Total Reward',
                    value: '$_totalRewards',
                    icon: Icons.emoji_events,
                    color: AppColors.warning,
                    subtitle: 'Reward diberikan',
                  ),
                ],
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: AppConstants.paddingMedium,
                crossAxisSpacing: AppConstants.paddingMedium,
                childAspectRatio: 1.5,
                children: [
                  UserStatsCard(
                    title: 'Total Users',
                    value: '$_totalUsers',
                    icon: Icons.people,
                    color: AppColors.primary,
                    subtitle: 'Pengguna terdaftar',
                  ),
                  UserStatsCard(
                    title: 'Total Botol',
                    value: '$_totalBottles',
                    icon: Icons.recycling,
                    color: AppColors.success,
                    subtitle: 'Botol terkumpul',
                  ),
                  UserStatsCard(
                    title: 'Total Reward',
                    value: '$_totalRewards',
                    icon: Icons.emoji_events,
                    color: AppColors.warning,
                    subtitle: 'Reward diberikan',
                  ),
                ],
              ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksi Cepat',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: const Icon(Icons.people, color: AppColors.primary),
              ),
              title: const Text('Kelola Users'),
              subtitle: const Text('Tambah botol, lihat semua user'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _onItemTapped(1),
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: const Icon(Icons.card_giftcard, color: AppColors.warning),
              ),
              title: const Text('Kelola Reward'),
              subtitle: const Text('Berikan reward ke top users'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}
