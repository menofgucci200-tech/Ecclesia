import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton.dart';

/// A pulsing placeholder shown while the parish list is loading.
class ParishListSkeleton extends StatelessWidget {
  const ParishListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonList(count: itemCount);
  }
}
