import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/market_data/models/candle.dart';
import '../../../core/network/api_client.dart';

class StockChartScreen extends StatefulWidget {
  const StockChartScreen({
    super.key,
    required this.symbol,
    required this.name,
    required this.instrumentKey,
  });

  final String symbol;
  final String name;
  final String instrumentKey;

  @override
  State<StockChartScreen> createState() => _StockChartScreenState();
}

class _StockChartScreenState extends State<StockChartScreen> {
  final ApiClient _api = ApiClient.instance;

  String _timeframe = '15 min';

  List<Candle> _candles = [];

  bool _loading = true;

  String? _error;

  double? _vwap;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final interval = _apiInterval(_timeframe);

      final now = DateTime.now();

      final from = now.subtract(
        const Duration(days: 5),
      );

      final fromDate = _formatDate(from);

      final toDate = _formatDate(now);

      final encodedInstrument =
          Uri.encodeQueryComponent(widget.instrumentKey);

      final response = await _api.get(
        '/broker/candles'
        '?instrumentKey=$encodedInstrument'
        '&interval=$interval'
        '&fromDate=$fromDate'
        '&toDate=$toDate',
      );

      final rawCandles =
          response['candles'] as List<dynamic>? ?? [];

      final parsed = <Candle>[];

      for (final raw in rawCandles) {
        if (raw is! Map) {
          continue;
        }

        final time =
            DateTime.tryParse(
          raw['timestamp']?.toString() ?? '',
        );

        if (time == null) {
          continue;
        }

        final open = _toDouble(raw['open']);
        final high = _toDouble(raw['high']);
        final low = _toDouble(raw['low']);
        final close = _toDouble(raw['close']);
        final volume = _toDouble(raw['volume']);

        if (open == null ||
            high == null ||
            low == null ||
            close == null ||
            volume == null) {
          continue;
        }

        parsed.add(
          Candle(
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            time: time,
          ),
        );
      }

      parsed.sort(
        (a, b) => a.time.compareTo(b.time),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _candles = parsed;
        _vwap = _toDouble(response['vwap']);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _apiInterval(String timeframe) {
    switch (timeframe) {
      case '1 min':
        return '1minute';

      case '5 min':
        return '5minute';

      case '15 min':
        return '15minute';

      case '30 min':
        return '30minute';

      case '1 hour':
        return '1hour';

      case '1 day':
        return 'day';

      default:
        return '15minute';
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest =
        _candles.isNotEmpty ? _candles.last : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.symbol,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPriceHeader(latest),
            _buildTimeframes(),
            Expanded(
              child: _buildChartBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceHeader(Candle? latest) {
    final price = latest?.close;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'LTP',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price == null
                      ? '--'
                      : '₹${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              const Text(
                'VWAP',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _vwap == null
                    ? '--'
                    : '₹${_vwap!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframes() {
    const timeframes = [
      '1 min',
      '5 min',
      '15 min',
      '30 min',
      '1 hour',
      '1 day',
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final timeframe = timeframes[index];

          final selected =
              timeframe == _timeframe;

          return ChoiceChip(
            label: Text(timeframe),
            selected: selected,
            onSelected: (_) {
              if (_timeframe == timeframe) {
                return;
              }

              setState(() {
                _timeframe = timeframe;
              });

              _loadChart();
            },
          );
        },
      ),
    );
  }

  Widget _buildChartBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load chart data',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _loadChart,
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      );
    }

    if (_candles.isEmpty) {
      return const Center(
        child: Text(
          'No historical candle data available.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        20,
      ),
      padding: const EdgeInsets.fromLTRB(
        8,
        16,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: CandlestickChart(
        CandlestickChartData(
          candlestickSpots:
              _buildCandlestickSpots(),
          minX: 0,
          maxX: _candles.length.toDouble(),
          gridData: const FlGridData(
            show: true,
          ),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 55,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          candlestickTouchData:
              CandlestickTouchData(
            enabled: true,
          ),
        ),
      ),
    );
  }

  List<CandlestickSpot> _buildCandlestickSpots() {
    return List.generate(
      _candles.length,
      (index) {
        final candle = _candles[index];

        return CandlestickSpot(
          x: index.toDouble(),
          open: candle.open,
          high: candle.high,
          low: candle.low,
          close: candle.close,
        );
      },
    );
  }
}