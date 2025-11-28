import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constantes/couleurs_app.dart';
import '../core/constantes/tailles_app.dart';

/// Widget pour afficher un skeleton loader avec effet shimmer
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CouleursApp.gris.withOpacity(0.3),
      highlightColor: CouleursApp.blanc.withOpacity(0.8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: CouleursApp.gris,
          borderRadius: borderRadius ?? BorderRadius.circular(TaillesApp.rayonMin),
        ),
      ),
    );
  }
}

/// Skeleton loader pour les cards de plats
class SkeletonPlatCard extends StatelessWidget {
  const SkeletonPlatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 150,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(TaillesApp.rayonMoyen),
              topRight: Radius.circular(TaillesApp.rayonMoyen),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                const SkeletonLoader(
                  width: 200,
                  height: 20,
                ),
                const SizedBox(height: 8),

                // Description ligne 1
                const SkeletonLoader(
                  width: double.infinity,
                  height: 14,
                ),
                const SizedBox(height: 4),

                // Description ligne 2
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14,
                ),
                const SizedBox(height: 12),

                // Bouton
                const SkeletonLoader(
                  width: double.infinity,
                  height: 40,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader pour les items de liste
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
      margin: const EdgeInsets.only(bottom: TaillesApp.espacementMin),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
      ),
      child: Row(
        children: [
          // Avatar/Icon
          const SkeletonLoader(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          const SizedBox(width: TaillesApp.espacementMoyen),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 16,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader pour une grille de cartes
class SkeletonGrid extends StatelessWidget {
  final int itemCount;

  const SkeletonGrid({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: TaillesApp.espacementMoyen,
        mainAxisSpacing: TaillesApp.espacementMoyen,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonPlatCard(),
    );
  }
}

/// Skeleton loader pour une liste
class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonListItem(),
    );
  }
}
