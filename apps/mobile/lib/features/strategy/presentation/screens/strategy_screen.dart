import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/strategy_model.dart';
import '../../providers/strategy_list_provider.dart';
import 'create_strategy_screen.dart';

class StrategyScreen extends ConsumerWidget {
  const StrategyScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(strategyListProvider);
    await ref.read(strategyListProvider.future);
  }

  Future<void> _openCreateStrategy(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateStrategyScreen()),
    );

    if (created == true) {
      ref.invalidate(strategyListProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategies = ref.watch(strategyListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        titleSpacing: AppSpacing.screenPadding,
        title: const Text('Strategies', style: AppTextStyles.headlineSmall),
      ),
      body: SafeArea(
        top: false,
        child: strategies.when(
          loading: () => const _LoadingState(),
          error: (error, _) => _ErrorState(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(strategyListProvider);
            },
          ),
          data: (data) {
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: data.isEmpty
                  ? _EmptyState(
                      onCreate: () => _openCreateStrategy(context, ref),
                    )
                  : _StrategyList(
                      strategies: data,
                      onCreate: () => _openCreateStrategy(context, ref),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _StrategyList extends StatelessWidget {
  final List<StrategyModel> strategies;
  final VoidCallback onCreate;

  const _StrategyList({required this.strategies, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final activeCount = strategies
        .where((strategy) => strategy.isActive)
        .length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.xxxl,
      ),
      children: [
        _StrategyHeader(
          totalStrategies: strategies.length,
          activeStrategies: activeCount,
          onCreate: onCreate,
        ),
        const SizedBox(height: AppSpacing.sectionSpacing),
        const Text('My Strategies', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ...strategies.map(
          (strategy) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _StrategyCard(strategy: strategy),
          ),
        ),
      ],
    );
  }
}

class _StrategyHeader extends StatelessWidget {
  final int totalStrategies;
  final int activeStrategies;
  final VoidCallback onCreate;

  const _StrategyHeader({
    required this.totalStrategies,
    required this.activeStrategies,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.lgBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_graph_rounded,
            color: AppColors.textWhite,
            size: 30,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Trade with a plan.',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            totalStrategies == 0
                ? 'Build rules for how you enter, manage and exit trades.'
                : '$activeStrategies of $totalStrategies strategies active.',
            style: const TextStyle(
              color: Color(0xFFEFF6FF),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Create Strategy',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StrategyCard extends StatelessWidget {
  final StrategyModel strategy;

  const _StrategyCard({required this.strategy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strategy.name, style: AppTextStyles.titleMedium),
                    if (strategy.description.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        strategy.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _StatusBadge(isActive: strategy.isActive),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: strategy.timeframe,
              ),
              _InfoChip(
                icon: Icons.shield_outlined,
                label: '1:${_formatRatio(strategy.riskRewardRatio)} R:R',
              ),
              _InfoChip(
                icon: Icons.repeat_rounded,
                label: '${strategy.maxTradesPerDay} trades/day',
              ),
              if (strategy.minimumAiScore > 0)
                _InfoChip(
                  icon: Icons.psychology_alt_outlined,
                  label: 'AI ${strategy.minimumAiScore}+',
                ),
            ],
          ),
          if (strategy.instruments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            Text(
              strategy.instruments.join(' • '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatRatio(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.neutral;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.pillBorder,
      ),
      child: Text(
        isActive ? 'Active' : 'Paused',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.pillBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.xxxl,
      ),
      children: [
        _StrategyHeader(
          totalStrategies: 0,
          activeStrategies: 0,
          onCreate: onCreate,
        ),
        const SizedBox(height: 48),
        const Icon(
          Icons.rule_folder_outlined,
          size: 58,
          color: AppColors.textHint,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'No strategies yet',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Create your first trading strategy and define the rules you want Quanttora to follow.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Unable to load strategies',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
