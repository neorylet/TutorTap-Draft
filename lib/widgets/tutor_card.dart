import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constants/cloudinary_config.dart';
import '../core/theme/app_colors.dart';
import '../models/tutor_profile.dart';
import 'status_badge.dart';

class TutorCard extends StatelessWidget {
  const TutorCard({
    super.key,
    required this.tutor,
    this.grid = false,
    this.onTap,
  });

  final TutorProfile tutor;
  final bool grid;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget avatar = Hero(
      tag: 'tutor-avatar-${tutor.uid}',
      child: CircleAvatar(
        radius: grid ? 24 : 22,
        backgroundColor: AppColors.mint,
        child: tutor.avatarUrl == null || tutor.avatarUrl!.isEmpty
            ? Text(
                tutor.initials,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.forest,
                ),
              )
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: CloudinaryConfig.avatarUrl(tutor.avatarUrl!),
                  width: grid ? 48 : 44,
                  height: grid ? 48 : 44,
                  fit: BoxFit.cover,
                  placeholder: (BuildContext context, String url) =>
                      const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (BuildContext context, String url, Object error) =>
                      Text(tutor.initials),
                ),
              ),
      ),
    );

    final Widget copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                tutor.displayName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 6),
            const StatusBadge(label: 'Verified', tone: StatusTone.positive),
          ],
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: tutor.subjects
              .map(
                (String subject) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.pistachio,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    subject,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: AppColors.forest,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 5),
        Text(
          '★ ${tutor.rating.toStringAsFixed(1)} (${tutor.ratingCount})',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '₱${tutor.hourlyRate.toStringAsFixed(0)}/hr',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.forest,
              ),
            ),
            const StatusBadge(label: 'Online', tone: StatusTone.positive),
          ],
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: grid
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[avatar, const SizedBox(height: 10), copy],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  avatar,
                  const SizedBox(width: 12),
                  Expanded(child: copy),
                ],
              ),
      ),
    );
  }
}
