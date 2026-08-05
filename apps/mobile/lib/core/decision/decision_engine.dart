import '../scoring/q_score.dart';
import 'decision.dart';

class DecisionEngine {
  const DecisionEngine();

  Decision evaluate(QScore score) {
    final strengths = <String>[];
    final weaknesses = <String>[];
    final confirmations = <String>[];

    for (final reason in score.reasons) {
      if (reason.contains("above") ||
          reason.contains("rising") ||
          reason.contains("Strong") ||
          reason.contains("healthy")) {
        strengths.add(reason);
      } else {
        weaknesses.add(reason);
      }
    }

    if (score.percentage < 90) {
      confirmations.add("Wait for stronger confirmation");
    }

    if (score.percentage < 80) {
      confirmations.add("Improve trend alignment");
    }

    if (score.percentage < 70) {
      confirmations.add("Avoid entering with weak momentum");
    }

    return Decision(
      score: score,
      marketReadiness: _marketReadiness(score.percentage),
      capitalProtection: _capitalProtection(score.percentage),
      probability: score.percentage,
      strategyAligned: score.percentage >= 75,
      strengths: strengths,
      weaknesses: weaknesses,
      nextConfirmations: confirmations,
    );
  }

  String _marketReadiness(double score) {
    if (score >= 90) return "Excellent";
    if (score >= 80) return "Strong";
    if (score >= 70) return "Healthy";
    if (score >= 60) return "Weak";
    return "Poor";
  }

  String _capitalProtection(double score) {
    if (score >= 90) return "Excellent";
    if (score >= 75) return "Good";
    if (score >= 60) return "Moderate";
    return "High Risk";
  }
}
