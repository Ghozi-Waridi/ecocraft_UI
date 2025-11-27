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

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final RewardService _rewardService = RewardService();

  int _selectedIndex = 0;
  int _totalUsers = 0;
  int _totalBottles = 0;
  int _totalRewards = 0;
  bool _isLoading = true;

  late AnimationController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageController.forward();
    _loadStats();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    if (_selectedIndex != index) {
      _pageController.reverse().then((_) {
        setState(() => _selectedIndex = index);
        _pageController.forward();
      });
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text('Keluar'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari panel admin?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      _buildHomeScreen(user),
      const UserManagementScreen(),
      const RewardManagementScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _pageController,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _pageController,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: screens[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            label: 'Rewards',
          ),
        ],
      ),
    );
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
            // Header with Animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Panel',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Selamat Datang, ${user.fullName}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: _loadStats,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _showLogoutDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(
                            Icons.logout_outlined,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
            else ...[
              // Stats Title
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 10 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statistik Sistem',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Overview',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Stats Cards with Animation
              if (isMobile)
                Column(
                  children: [
                    _buildAnimatedStatsCard(
                      delay: 0,
                      title: 'Total Users',
                      value: '$_totalUsers',
                      icon: Icons.people,
                      color: AppColors.primary,
                      subtitle: 'Pengguna terdaftar',
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildAnimatedStatsCard(
                      delay: 100,
                      title: 'Total Botol',
                      value: '$_totalBottles',
                      icon: Icons.recycling,
                      color: AppColors.success,
                      subtitle: 'Botol terkumpul',
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildAnimatedStatsCard(
                      delay: 200,
                      title: 'Total Reward',
                      value: '$_totalRewards',
                      icon: Icons.emoji_events,
                      color: AppColors.warning,
                      subtitle: 'Reward diberikan',
                    ),
                  ],
                )
              else
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: 200,
                        child: _buildAnimatedStatsCard(
                          delay: 0,
                          title: 'Total Users',
                          value: '$_totalUsers',
                          icon: Icons.people,
                          color: AppColors.primary,
                          subtitle: 'Pengguna terdaftar',
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: _buildAnimatedStatsCard(
                          delay: 100,
                          title: 'Total Botol',
                          value: '$_totalBottles',
                          icon: Icons.recycling,
                          color: AppColors.success,
                          subtitle: 'Botol terkumpul',
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: _buildAnimatedStatsCard(
                          delay: 200,
                          title: 'Total Reward',
                          value: '$_totalRewards',
                          icon: Icons.emoji_events,
                          color: AppColors.warning,
                          subtitle: 'Reward diberikan',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: AppConstants.paddingLarge),

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatsCard({
    required int delay,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue.clamp(0.0, 1.0),
          child: Opacity(opacity: animValue.clamp(0.0, 1.0), child: child),
        );
      },
      child: UserStatsCard(
        title: title,
        value: value,
        icon: icon,
        color: color,
        subtitle: subtitle,
      ),
    );
  }

  Widget _buildQuickActions() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aksi Cepat', style: AppTextStyles.h3),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildAnimatedListTile(
                delay: 100,
                leading: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                  ),
                  child: const Icon(Icons.people, color: AppColors.primary),
                ),
                title: 'Kelola Users',
                subtitle: 'Tambah botol, lihat semua user',
                onTap: () => _onItemTapped(1),
              ),
              const Divider(),
              _buildAnimatedListTile(
                delay: 200,
                leading: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: AppColors.warning,
                  ),
                ),
                title: 'Kelola Reward',
                subtitle: 'Berikan reward ke top users',
                onTap: () => _onItemTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedListTile({
    required int delay,
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          child: ListTile(
            leading: leading,
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ),
    );
  }
}
