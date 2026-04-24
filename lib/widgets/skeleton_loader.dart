// FILE: lib/widgets/skeleton_loader.dart
import 'package:flutter/material.dart';

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

class EstablishmentSkeletonTile extends StatelessWidget {
  const EstablishmentSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const SkeletonBox(width: 56, height: 56, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(height: 14),
                  const SizedBox(height: 6),
                  SkeletonBox(width: MediaQuery.of(context).size.width * 0.4, height: 11),
                  const SizedBox(height: 4),
                  SkeletonBox(width: MediaQuery.of(context).size.width * 0.5, height: 11),
                  const SizedBox(height: 4),
                  SkeletonBox(width: MediaQuery.of(context).size.width * 0.3, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCardSkeleton extends StatelessWidget {
  const SummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 28, height: 28, borderRadius: 4),
            const SizedBox(height: 8),
            const SkeletonBox(width: 60, height: 28, borderRadius: 4),
            const SizedBox(height: 4),
            SkeletonBox(width: MediaQuery.of(context).size.width * 0.2, height: 13),
          ],
        ),
      ),
    );
  }
}

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(height: 200);
  }
}
