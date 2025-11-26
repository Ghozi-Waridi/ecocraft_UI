import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/user_stats_card.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import '../auth/login_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch leaderboard on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaderboardProvider>(context, listen: false).fetchLeaderboard();
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
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<LeaderboardProvider>(context, listen: false).refresh();
              authProvider.refreshUser();
            },
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
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Leaderboard';
      case 2:
        return 'Profil';
      default:
        return AppConstants.appName;
    }
  }

  Widget _buildHomeScreen(user) {
    final isMobile = Breakpoints.isMobile(context);

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<AuthProvider>(context, listen: false).refreshUser();
        await Provider.of<LeaderboardProvider>(context, listen: false).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Halo, ${user.fullName}! 👋',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Terus kumpulkan botol dan raih posisi teratas!',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 1 : 2,
              mainAxisSpacing: AppConstants.paddingMedium,
              crossAxisSpacing: AppConstants.paddingMedium,
              childAspectRatio: isMobile ? 3 : 2,
              children: [
                UserStatsCard(
                  title: 'Total Botol',
                  value: '${user.totalBottles}',
                  icon: Icons.recycling,
                  color: AppColors.primary,
                  subtitle: 'Botol terkumpul',
                ),
                Consumer<LeaderboardProvider>(
                  builder: (context, leaderboardProvider, _) {
                    return FutureBuilder<int?>(
                      future: leaderboardProvider.getUserRank(user.id),
                      builder: (context, snapshot) {
                        final rank = snapshot.data;
                        return UserStatsCard(
                          title: 'Peringkat',
                          value: rank != null ? '#$rank' : '-',
                          icon: Icons.emoji_events,
                          color: AppColors.accent,
                          subtitle: 'Posisi saat ini',
                        );
                      },
                    );
                  },
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
                child: const Icon(Icons.leaderboard, color: AppColors.primary),
              ),
              title: const Text('Lihat Leaderboard'),
              subtitle: const Text('Cek posisi kamu di peringkat'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _onItemTapped(1),
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: const Icon(Icons.card_giftcard, color: AppColors.accent),
              ),
              title: const Text('Riwayat Reward'),
              subtitle: const Text('Lihat hadiah yang kamu dapatkan'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}
