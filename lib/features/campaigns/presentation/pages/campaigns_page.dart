import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: AppTheme.paddingL),
            Text(
              'Campaigns',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.paddingM),
            Text(
              'Browse and support Palestinian causes',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
