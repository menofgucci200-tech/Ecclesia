import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/support_badge.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../router/app_routes.dart';
import '../../data/models/parish_model.dart';
import '../providers/parish_list_controller.dart';
import '../providers/parish_list_state.dart';
import '../widgets/parish_card.dart';
import '../widgets/parish_card_skeleton.dart';
import '../widgets/parish_search_field.dart';

/// Screen 1 of the parish selection flow: search + list + selection.
class ChooseParishScreen extends ConsumerStatefulWidget {
  const ChooseParishScreen({super.key});

  @override
  ConsumerState<ChooseParishScreen> createState() => _ChooseParishScreenState();
}

class _ChooseParishScreenState extends ConsumerState<ChooseParishScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  ParishModel? _selected;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      ref.read(parishListControllerProvider.notifier).loadMore();
    }
  }

  void _onContinue() {
    if (_selected == null) return;
    context.push(AppRoutes.confirmParish, extra: _selected!.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listAsync = ref.watch(parishListControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.sm),
              Row(
                children: [
                  if (context.canPop())
                    IconButton(
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.navyDark),
                    ),
                  const Spacer(),
                  const SupportBadge(),
                ],
              ),
              const SizedBox(height: AppDimens.lg),
              Text('Choisissez votre paroisse', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppDimens.sm),
              Text(
                'Entrez le code de votre paroisse ou recherchez-la dans la liste ci-dessous '
                'afin de commencer votre expérience sur Ecclesia. Vous pourrez modifier ce '
                'choix à tout moment depuis votre profil.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimens.lg),
              ParishSearchField(
                controller: _searchController,
                onChanged: (value) =>
                    ref.read(parishListControllerProvider.notifier).search(value),
              ),
              const SizedBox(height: AppDimens.md),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.navy,
                  onRefresh: () =>
                      ref.read(parishListControllerProvider.notifier).refresh(),
                  child: listAsync.when(
                    loading: () => const ParishListSkeleton(),
                    error: (error, _) => _ErrorState(
                      message: error is ApiException ? error.message : 'Une erreur est survenue.',
                      onRetry: () => ref.invalidate(parishListControllerProvider),
                    ),
                    data: (state) => _ParishList(
                      state: state,
                      scrollController: _scrollController,
                      selectedId: _selected?.id,
                      onSelect: (parish) => setState(() => _selected = parish),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
                child: PrimaryButton(
                  label: 'Continuer',
                  isEnabled: _selected != null,
                  onPressed: _onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParishList extends StatelessWidget {
  const _ParishList({
    required this.state,
    required this.scrollController,
    required this.selectedId,
    required this.onSelect,
  });

  final ParishListState state;
  final ScrollController scrollController;
  final int? selectedId;
  final ValueChanged<ParishModel> onSelect;

  @override
  Widget build(BuildContext context) {
    if (state.isEmpty) {
      return ListView(
        controller: scrollController,
        children: const [
          SizedBox(height: 80),
          _EmptyState(),
        ],
      );
    }

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.parishes.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.md),
      itemBuilder: (context, index) {
        if (index >= state.parishes.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.lg),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final parish = state.parishes[index];
        return ParishCard(
          parish: parish,
          selected: selectedId == parish.id,
          onTap: () => onSelect(parish),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.xl),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 40, color: AppColors.textHint),
            SizedBox(height: AppDimens.md),
            Text(
              'Aucune paroisse ne correspond à votre recherche.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.error),
        const SizedBox(height: AppDimens.md),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: AppDimens.lg),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ),
      ],
    );
  }
}
