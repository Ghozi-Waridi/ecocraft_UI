import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/user_service.dart';
import '../../services/reward_service.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class RewardManagementScreen extends StatefulWidget {
  const RewardManagementScreen({super.key});

  @override
  State<RewardManagementScreen> createState() => _RewardManagementScreenState();
}

class _RewardManagementScreenState extends State<RewardManagementScreen> {
  final UserService _userService = UserService();
  final RewardService _rewardService = RewardService();
  
  bool _isLoading = false;

  Future<void> _showCreateRewardDialog() async {
    final users = await _userService.getAllUsers();
    
    if (!mounted) return;
    
    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada user untuk diberi reward'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    UserModel? selectedUser;
    final nameController = TextEditingController();
    final descController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Buat Reward Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Selection
                DropdownButtonFormField<UserModel>(
                  value: selectedUser,
                  decoration: const InputDecoration(
                    labelText: 'Pilih User',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: users.map((user) {
                    return DropdownMenuItem(
                      value: user,
                      child: Text('${user.fullName} (${user.totalBottles} botol)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedUser = value;
                    });
                  },
                ),
                const SizedBox(height: AppConstants.paddingMedium),

                // Reward Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Reward',
                    hintText: 'Contoh: Juara 1 Bulan Ini',
                    prefixIcon: Icon(Icons.emoji_events),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),

                // Reward Description
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Reward',
                    hintText: 'Contoh: Voucher Belanja Rp 100.000',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedUser != null && nameController.text.isNotEmpty) {
                  Navigator.pop(context);
                  await _createReward(
                    selectedUser!,
                    nameController.text,
                    descController.text.isEmpty ? null : descController.text,
                  );
                }
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createReward(UserModel user, String name, String? description) async {
    setState(() => _isLoading = true);

    final reward = await _rewardService.createReward(
      userId: user.id,
      rewardName: name,
      rewardDescription: description,
      bottlesCount: user.totalBottles,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (reward != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reward berhasil diberikan ke ${user.fullName}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat reward'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _awardTopThree() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Berikan reward otomatis ke top 3 users?\n\n'
          '🥇 Juara 1: Voucher Rp 100.000\n'
          '🥈 Juara 2: Voucher Rp 50.000\n'
          '🥉 Juara 3: Voucher Rp 25.000',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Berikan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final rewards = await _rewardService.awardTopThree();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (rewards.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil memberikan ${rewards.length} reward'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memberikan reward'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Reward Management',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Berikan reward kepada user yang berprestasi',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Action Cards
          Expanded(
            child: Breakpoints.isMobile(context)
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildActionCard(
                          title: 'Buat Reward Manual',
                          description: 'Pilih user dan berikan reward secara manual',
                          icon: Icons.add_circle,
                          color: AppColors.primary,
                          onTap: _showCreateRewardDialog,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        _buildActionCard(
                          title: 'Award Top 3',
                          description: 'Berikan reward otomatis ke 3 user teratas',
                          icon: Icons.emoji_events,
                          color: AppColors.warning,
                          onTap: _awardTopThree,
                        ),
                      ],
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppConstants.paddingMedium,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    childAspectRatio: 2,
                    children: [
                      _buildActionCard(
                        title: 'Buat Reward Manual',
                        description: 'Pilih user dan berikan reward secara manual',
                        icon: Icons.add_circle,
                        color: AppColors.primary,
                        onTap: _showCreateRewardDialog,
                      ),
                      _buildActionCard(
                        title: 'Award Top 3',
                        description: 'Berikan reward otomatis ke 3 user teratas',
                        icon: Icons.emoji_events,
                        color: AppColors.warning,
                        onTap: _awardTopThree,
                      ),
                    ],
                  ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Flexible(
                child: Text(
                  description,
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
