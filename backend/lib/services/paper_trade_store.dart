import 'package:backend/models/paper_trade.dart';

class PaperTradeStore {
  PaperTradeStore._();

  static final PaperTradeStore instance = PaperTradeStore._();

  final List<PaperTrade> _trades = [];

  int get count => _trades.length;

  PaperTrade create({
    required String instrumentToken,
    required int quantity,
    required String product,
    required String validity,
    required double entryPrice,
    required String orderType,
    required String transactionType,
  }) {
    final now = DateTime.now().toUtc();
    final id = 'PT-${now.millisecondsSinceEpoch}-${_trades.length + 1}';

    final trade = PaperTrade(
      id: id,
      instrumentToken: instrumentToken,
      quantity: quantity,
      product: product,
      validity: validity,
      entryPrice: entryPrice,
      currentPrice: entryPrice,
      orderType: orderType,
      transactionType: transactionType,
      status: 'OPEN',
      createdAt: now,
      updatedAt: now,
    );

    _trades.insert(0, trade);
    return trade;
  }

  PaperTrade? getById(String id) {
    for (final trade in _trades) {
      if (trade.id == id) {
        return trade;
      }
    }

    return null;
  }

  List<PaperTrade> getAll() {
    return List<PaperTrade>.unmodifiable(_trades);
  }

  List<PaperTrade> getOpen() {
    return _trades
        .where((trade) => trade.status == 'OPEN')
        .toList(growable: false);
  }

  PaperTrade? updatePrice({required String id, required double currentPrice}) {
    final index = _trades.indexWhere((trade) => trade.id == id);

    if (index == -1) {
      return null;
    }

    final updated = _trades[index].copyWith(
      currentPrice: currentPrice,
      updatedAt: DateTime.now().toUtc(),
    );

    _trades[index] = updated;
    return updated;
  }

  PaperTrade? close(String id) {
    final index = _trades.indexWhere((trade) => trade.id == id);

    if (index == -1) {
      return null;
    }

    final updated = _trades[index].copyWith(
      status: 'CLOSED',
      updatedAt: DateTime.now().toUtc(),
    );

    _trades[index] = updated;
    return updated;
  }

  void clear() {
    _trades.clear();
  }
}
