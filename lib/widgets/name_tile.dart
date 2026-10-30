import 'package:arabic_names/Model/names_model.dart';
import 'package:arabic_names/theme/app_theme.dart';
import 'package:arabic_names/widgets/ornaments.dart';
import 'package:flutter/material.dart';

/// One row of a names list: letter medallion, Arabic name in Naskh, English name,
/// short meaning and a favourite heart.
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

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 5, 14, 5),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 2, 10),
            child: Row(
              children: [
                StarMedallion(
                  size: 50,
                  child: Text(
                    name.letter,
                    style: const TextStyle(
                      fontFamily: AppFonts.naskh,
                      color: AppColors.emerald,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              name.urduName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppFonts.naskh,
                                color: AppColors.ink,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                height: 1.35,
                              ),
                            ),
                          ),
                          if (english != null) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                english,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (meaning != null)
                        Text(
                          meaning,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 14),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFavourite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                  onPressed: onToggleFavourite,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isFavourite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFavourite),
                      color: isFavourite ? AppColors.favourite : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
