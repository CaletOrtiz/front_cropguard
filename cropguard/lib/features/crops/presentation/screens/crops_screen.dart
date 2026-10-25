import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/features/crops/domain/entities/crop.dart';
import 'package:kroppi/navigation/app_routes.dart';
import 'package:kroppi/features/crops/presentation/widgets/crop_card.dart';
import 'package:kroppi/features/crops/presentation/widgets/crop_search_field.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Minúsculas y sin tildes, para que "tizon" encuentre "Tizón".
  static String _normalize(String text) {
    const from = 'áàäâéèëêíìïîóòöôúùüûñ';
    const to = 'aaaaeeeeiiiioooouuuun';
    var out = text.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  List<Crop> get _filteredCrops {
    final q = _normalize(_query.trim());
    if (q.isEmpty) return AppCrops.all;
    return AppCrops.all.where((crop) {
      return _normalize(crop.name).contains(q) ||
          crop.commonDiseases.any((d) => _normalize(d).contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final crops = _filteredCrops;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F3DD), Colors.white],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Flexible(
                            child: Text(
                              AppStrings.cropsTitle,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.eco_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        AppStrings.cropsSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      CropSearchField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              if (crops.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        AppStrings.noCropsFound,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.82,
                        ),
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      return CropCard(
                        crop: crop,
                        onTap: () =>
                            context.push(AppRoutes.cropDetailPath(crop.id)),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
