import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One row of a names list: Arabic name, English name, short meaning, favourite heart.
class NameTile extends StatelessWidget {
  const NameTile({
    super.key,
    required this.name,
    required this.isFavourite,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final NameModel name;
  final bool isFavourite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final english = name.englishName;
    final meaning = name.urduMeaning;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: AppColors.surface.withValues(alpha: 0.92),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 4, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.accent.withValues(alpha: 0.18),
                child: Text(
                  name.letter,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.urduName ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (english != null)
                      Text(
                        english,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    if (meaning != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          meaning,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavourite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                onPressed: onToggleFavourite,
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: isFavourite ? AppColors.favourite : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
