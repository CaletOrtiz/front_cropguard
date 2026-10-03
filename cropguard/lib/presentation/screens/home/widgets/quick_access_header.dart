import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';

class QuickAccessHeader extends StatelessWidget {
  const QuickAccessHeader({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            AppStrings.quickAccess,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.only(left: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.seeAll,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
      ],
    );
  }
}
