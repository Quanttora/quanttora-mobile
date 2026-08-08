import 'analysis_session.dart';

class AnalysisHistory {
  static final List<AnalysisSession> _history = [];

  static void add(AnalysisSession session) {
    _history.add(session);
  }

  static List<AnalysisSession> getAll() {
    return List.unmodifiable(_history);
  }

  static AnalysisSession? latest() {
    if (_history.isEmpty) return null;
    return _history.last;
  }

  static int totalSessions() {
    return _history.length;
  }

  static void clear() {
    _history.clear();
  }
}
