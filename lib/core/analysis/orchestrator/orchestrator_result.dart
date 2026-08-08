import '../../../features/trade_analysis/models/analysis_result.dart';

class OrchestratorResult {
  final AnalysisResult analysis;

  final bool blocked;

  final String blockReason;

  const OrchestratorResult({
    required this.analysis,
    required this.blocked,
    required this.blockReason,
  });
}
