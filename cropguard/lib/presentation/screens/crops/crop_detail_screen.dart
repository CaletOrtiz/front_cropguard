import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/models/crop.dart';
import 'package:kroppi/presentation/common/bullet_list.dart';
import 'package:kroppi/presentation/common/crop_visual.dart';

class CropDetailScreen extends StatelessWidget {
  const CropDetailScreen({super.key, required this.cropId});

  final String cropId;

  @override
  Widget build(BuildContext context) {
    final crop = AppCrops.byId(cropId);

    if (crop == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Cultivo no encontrado')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(crop.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CropVisual(
                    cropId: crop.id,
                    borderRadius: BorderRadius.zero,
                    iconSize: 96,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(
                    title: AppStrings.commonDiseases,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: crop.commonDiseases
                            .map(
                              (d) => Chip(
                                label: Text(
                                  d,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: AppColors.primaryLight,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  _Section(
                    title: AppStrings.characteristicSymptoms,
                    children: [BulletList(items: crop.symptoms)],
                  ),
                  _Section(
                    title: AppStrings.monitoringTipsTitle,
                    children: [
                      BulletList(
                        items: crop.monitoringTips,
                        icon: Icons.visibility_rounded,
                      ),
                    ],
                  ),
                  _Section(
                    title: AppStrings.preventionTipsTitle,
                    children: [
                      BulletList(
                        items: crop.preventionTips,
                        icon: Icons.shield_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
