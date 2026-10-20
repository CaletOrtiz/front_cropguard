import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';

class BulletList extends StatelessWidget {
  const BulletList({super.key, required this.items, this.icon = Icons.circle});

  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 10),
                    child: Icon(icon, size: 6, color: AppColors.primary),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
