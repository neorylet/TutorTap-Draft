import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class MeetingLinkBox extends StatelessWidget {
  const MeetingLinkBox({
    super.key,
    required this.link,
    this.room,
    this.note,
    this.onCopy,
  });

  final String link;
  final String? room;
  final String? note;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.videocam_outlined, color: AppColors.emerald, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  link.isEmpty ? (room ?? 'Online session') : link,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.forest,
                    fontSize: 11,
                  ),
                ),
                if (note != null && note!.isNotEmpty)
                  Text(note!, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          if (onCopy != null)
            TextButton(
              onPressed: onCopy,
              child: Text(
                'Copy',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
  }
}
