import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/controllers/campaign_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user.dart' as app_models;
import '../../../../shared/presentation/widgets/campaign_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    final campaignController = Get.find<CampaignController>();
    await campaignController.loadCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return GetBuilder<CampaignController>(
          builder: (campaignController) {
            final user = authController.currentUser;
            final campaigns = campaignController.campaigns;
            
            return RefreshIndicator(
              onRefresh: _loadCampaigns,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.paddingL),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.displayName ?? 'Friend'}!',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeL,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppTheme.paddingS),
                          const Text(
                            'Together, we amplify Palestinian voices and support their struggle for justice.',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeS,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingL),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'Create Campaign',
                            onTap: () {
                              if (user?.status == app_models.UserStatus.verified) {
                                context.push('/create-campaign');
                              } else {
                                _showVerificationDialog(context);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppTheme.paddingM),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.search,
                            label: 'Browse All',
                            onTap: () {
                              context.push('/campaigns');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingL),

                    // Featured campaigns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Featured Campaigns',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/campaigns');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingM),

                    // Campaigns list
                    if (campaignController.isLoading && campaigns.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.paddingL),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (campaigns.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.paddingL),
                          child: Text(
                            'No campaigns available at the moment.',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeM,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: campaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = campaigns[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.paddingM),
                            child: CampaignCard(
                              campaign: campaign,
                              onTap: () {
                                context.push('/campaign/${campaign.id}');
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppTheme.iconSizeL,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: AppTheme.paddingS),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Required'),
        content: const Text(
          'You need to be verified to create campaigns. Would you like to start the verification process?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/verification');
            },
            child: const Text('Get Verified'),
          ),
        ],
      ),
    );
  }
}
