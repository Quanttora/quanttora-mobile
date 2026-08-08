import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase_strategy_repository.dart';
import '../../models/strategy_model.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CreateStrategyScreen extends StatefulWidget {
  const CreateStrategyScreen({super.key});

  @override
  State<CreateStrategyScreen> createState() => _CreateStrategyScreenState();
}

class _CreateStrategyScreenState extends State<CreateStrategyScreen> {
  final _formKey = GlobalKey<FormState>();

  final SupabaseStrategyRepository _strategyRepository =
      SupabaseStrategyRepository();

  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  static const _instruments = <String>['NIFTY 50', 'BANK NIFTY', 'SENSEX'];

  static const _timeframes = <String>[
    '1 min',
    '3 min',
    '5 min',
    '15 min',
    '30 min',
    '1 hour',
    '1 day',
  ];

  final Set<String> _selectedInstruments = {};

  String _timeframe = '3 min';

  double _riskRewardRatio = 2;
  double _minimumAiScore = 80;

  int _maxTradesPerDay = 3;

  bool _avoidNews = true;
  bool _avoidSideways = true;
  bool _avoidLowVolume = true;

  int _step = 0;

  static const _stepTitles = <String>[
    'Basics',
    'Market',
    'Risk',
    'Filters',
    'Review',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    if (_step == 0) {
      return _formKey.currentState?.validate() ?? false;
    }

    if (_step == 1 && _selectedInstruments.isEmpty) {
      _showMessage('Select at least one instrument.');
      return false;
    }

    return true;
  }

  void _next() {
    if (!_validateCurrentStep()) {
      return;
    }

    if (_step < _stepTitles.length - 1) {
      setState(() {
        _step++;
      });
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() {
        _step--;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_validateCurrentStep()) {
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showMessage('Please sign in before saving a strategy.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();

      final strategy = StrategyModel(
        id: '',
        userId: user.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        timeframe: _timeframe,
        instruments: _selectedInstruments.toList(),
        minimumAiScore: _minimumAiScore.round(),
        riskRewardRatio: _riskRewardRatio,
        maxTradesPerDay: _maxTradesPerDay,
        avoidNews: _avoidNews,
        avoidSideways: _avoidSideways,
        avoidLowVolume: _avoidLowVolume,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await _strategyRepository.createStrategy(strategy);

      if (!mounted) {
        return;
      }

      _showMessage('Strategy saved successfully.');

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to save strategy: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Create Strategy',
          style: AppTextStyles.headlineSmall,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _ProgressHeader(currentStep: _step, titles: _stepTitles),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.xl,
                    AppSpacing.screenPadding,
                    AppSpacing.xxxl,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStep(),
                    ),
                  ),
                ),
              ),
            ),
            _BottomActions(
              isFirstStep: _step == 0,
              isLastStep: _step == _stepTitles.length - 1,
              onBack: _back,
              onNext: _next,
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildBasics();
      case 1:
        return _buildMarket();
      case 2:
        return _buildRisk();
      case 3:
        return _buildFilters();
      case 4:
        return _buildReview();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: 'Build your trading plan',
          description:
              'Give your strategy a clear identity. You can refine its trading rules later.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _FieldLabel('Strategy name'),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 50,
          decoration: const InputDecoration(hintText: 'e.g. Nifty Momentum'),
          validator: (value) {
            final name = value?.trim() ?? '';

            if (name.isEmpty) {
              return 'Enter a strategy name.';
            }

            if (name.length < 3) {
              return 'Use at least 3 characters.';
            }

            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        const _FieldLabel('Description'),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _descriptionController,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 4,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'Describe when and why you use this strategy.',
          ),
        ),
      ],
    );
  }

  Widget _buildMarket() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: 'Choose your market',
          description: 'Select where this strategy is allowed to operate.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _FieldLabel('Instruments'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _instruments.map((instrument) {
            final selected = _selectedInstruments.contains(instrument);

            return FilterChip(
              selected: selected,
              label: Text(instrument),
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _selectedInstruments.add(instrument);
                  } else {
                    _selectedInstruments.remove(instrument);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _FieldLabel('Timeframe'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _timeframes.map((timeframe) {
            return ChoiceChip(
              selected: _timeframe == timeframe,
              label: Text(timeframe),
              onSelected: (_) {
                setState(() {
                  _timeframe = timeframe;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRisk() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: 'Define your risk rules',
          description:
              'These limits help prevent a strategy from becoming an uncontrolled trade.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        _SettingCard(
          title: 'Risk / Reward',
          value: '1:${_formatNumber(_riskRewardRatio)}',
          description: 'Minimum reward expected for every unit of risk.',
          child: Slider(
            min: 1,
            max: 5,
            divisions: 8,
            value: _riskRewardRatio,
            label: '1:${_formatNumber(_riskRewardRatio)}',
            onChanged: (value) {
              setState(() {
                _riskRewardRatio = value;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingCard(
          title: 'Maximum trades per day',
          value: _maxTradesPerDay.toString(),
          description:
              'Maximum number of trades this strategy may allow in one trading day.',
          child: Slider(
            min: 1,
            max: 10,
            divisions: 9,
            value: _maxTradesPerDay.toDouble(),
            label: _maxTradesPerDay.toString(),
            onChanged: (value) {
              setState(() {
                _maxTradesPerDay = value.round();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: 'Add Quanttora filters',
          description:
              'Set the minimum conditions required before the strategy can qualify a trade.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        _SettingCard(
          title: 'Minimum AI score',
          value: '${_minimumAiScore.round()} / 100',
          description:
              'Required Quanttora analysis score before a trade qualifies.',
          child: Slider(
            min: 50,
            max: 100,
            divisions: 10,
            value: _minimumAiScore,
            label: _minimumAiScore.round().toString(),
            onChanged: (value) {
              setState(() {
                _minimumAiScore = value;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _FilterSwitch(
          title: 'Avoid major news',
          description:
              'Block qualifying trades when major market-moving news risk is detected.',
          value: _avoidNews,
          onChanged: (value) {
            setState(() {
              _avoidNews = value;
            });
          },
        ),
        _FilterSwitch(
          title: 'Avoid sideways markets',
          description: 'Require sufficient directional market structure.',
          value: _avoidSideways,
          onChanged: (value) {
            setState(() {
              _avoidSideways = value;
            });
          },
        ),
        _FilterSwitch(
          title: 'Avoid low volume',
          description:
              'Reject conditions where market participation is insufficient.',
          value: _avoidLowVolume,
          onChanged: (value) {
            setState(() {
              _avoidLowVolume = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReview() {
    final description = _descriptionController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: 'Review your strategy',
          description: 'Confirm the strategy controls before saving.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        _ReviewCard(
          children: [
            _ReviewRow(label: 'Strategy', value: _nameController.text.trim()),
            if (description.isNotEmpty)
              _ReviewRow(label: 'Description', value: description),
            _ReviewRow(
              label: 'Instruments',
              value: _selectedInstruments.join(', '),
            ),
            _ReviewRow(label: 'Timeframe', value: _timeframe),
            _ReviewRow(
              label: 'Risk / Reward',
              value: '1:${_formatNumber(_riskRewardRatio)}',
            ),
            _ReviewRow(
              label: 'Max trades/day',
              value: _maxTradesPerDay.toString(),
            ),
            _ReviewRow(
              label: 'Minimum AI score',
              value: '${_minimumAiScore.round()}',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _ReviewCard(
          children: [
            _BooleanReviewRow(label: 'Major news filter', enabled: _avoidNews),
            _BooleanReviewRow(
              label: 'Sideways market filter',
              enabled: _avoidSideways,
            ),
            _BooleanReviewRow(
              label: 'Low volume filter',
              enabled: _avoidLowVolume,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Creating a strategy defines your trading rules. It does not place an order or activate automated execution.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}

class _ProgressHeader extends StatelessWidget {
  final int currentStep;
  final List<String> titles;

  const _ProgressHeader({required this.currentStep, required this.titles});

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / titles.length;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Step ${currentStep + 1} of ${titles.length}',
                style: AppTextStyles.labelMedium,
              ),
              const Spacer(),
              Text(
                titles[currentStep],
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pillBorder,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceAlt,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  final String title;
  final String description;

  const _StepHeading({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(description, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.labelLarge);
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final Widget child;

  const _SettingCard({
    required this.title,
    required this.value,
    required this.description,
    required this.child,
  });

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
            children: [
              Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterSwitch({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final List<Widget> children;

  const _ReviewCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.labelMedium),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _BooleanReviewRow extends StatelessWidget {
  final String label;
  final bool enabled;

  const _BooleanReviewRow({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.cancel_outlined,
            color: enabled ? AppColors.success : AppColors.neutral,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            enabled ? 'Enabled' : 'Disabled',
            style: AppTextStyles.labelLarge.copyWith(
              color: enabled ? AppColors.success : AppColors.neutral,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool isFirstStep;
  final bool isLastStep;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSave;

  const _BottomActions({
    required this.isFirstStep,
    required this.isLastStep,
    required this.onBack,
    required this.onNext,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (!isFirstStep) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: isFirstStep ? 1 : 2,
            child: FilledButton(
              onPressed: isLastStep ? onSave : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              child: Text(
                isLastStep ? 'Save Strategy' : 'Continue',
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
