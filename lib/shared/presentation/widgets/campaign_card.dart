import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/campaign.dart';
import '../../../core/theme/app_theme.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.cardRadius),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: campaign.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: campaign.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.backgroundColor,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.backgroundColor,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: AppTheme.iconSizeL,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.backgroundColor,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: AppTheme.iconSizeL,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
              ),
            ),
            
            // Campaign content
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeM,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.paddingS),
                  
                  // Short description
                  Text(
                    campaign.shortDescription,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeS,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.paddingM),
                  
                  // Progress bar
                  LinearProgressIndicator(
                    value: campaign.progressPercentage / 100,
                    backgroundColor: AppTheme.backgroundColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(height: AppTheme.paddingS),
                  
                  // Progress info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${campaign.currentAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeS,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            'of \$${campaign.goalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeXS,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${campaign.progressPercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${campaign.daysLeft} days left',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeXS,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingM),
                  
                  // Bottom info
                  Row(
                    children: [
                      // Creator info
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          campaign.creator?.displayName.isNotEmpty == true
                              ? campaign.creator!.displayName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeXS,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.paddingS),
                      Expanded(
                        child: Text(
                          'by ${campaign.creator?.displayName ?? 'Anonymous'}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeXS,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        ),
                        child: Text(
                          campaign.category.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
