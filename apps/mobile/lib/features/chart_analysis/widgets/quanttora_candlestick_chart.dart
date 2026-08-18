import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/market_data/models/candle.dart';

class QuanttoraCandlestickChart extends StatelessWidget {
  const QuanttoraCandlestickChart({
    super.key,
    required this.candles,
    this.height = 420,
    this.showVolume = true,
    this.onCandleTap,
  });

  final List<Candle> candles;
  final double height;
  final bool showVolume;
  final void Function(Candle candle)? onCandleTap;

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No candle data available',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    final visibleCandles = List<Candle>.from(candles)
      ..sort((a, b) => a.time.compareTo(b.time));

    final spots = <CandlestickSpot>[];

    for (var i = 0; i < visibleCandles.length; i++) {
      final candle = visibleCandles[i];

      spots.add(
        CandlestickSpot(
          x: i.toDouble(),
          open: candle.open,
          high: candle.high,
          low: candle.low,
          close: candle.close,
        ),
      );
    }

    final prices = <double>[
      ...visibleCandles.map((candle) => candle.high),
      ...visibleCandles.map((candle) => candle.low),
    ];

    var minPrice = prices.reduce((a, b) => a < b ? a : b);

    var maxPrice = prices.reduce((a, b) => a > b ? a : b);

    if (minPrice == maxPrice) {
      minPrice -= 1;
      maxPrice += 1;
    }

    final padding = (maxPrice - minPrice) * 0.05;

    minPrice -= padding;
    maxPrice += padding;

    final chart = CandlestickChart(
      CandlestickChartData(
        minX: 0,
        maxX: (visibleCandles.length - 1).toDouble(),
        minY: minPrice,
        maxY: maxPrice,
        candlestickSpots: spots,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _gridInterval(minPrice, maxPrice),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 58,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: _bottomTitleInterval(visibleCandles.length),
              getTitlesWidget: (value, meta) {
                final index = value.round();

                if (index < 0 || index >= visibleCandles.length) {
                  return const SizedBox.shrink();
                }

                final time = visibleCandles[index].time;

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatTime(time),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        candlestickPainter: DefaultCandlestickPainter(),
        candlestickTouchData: CandlestickTouchData(
          enabled: onCandleTap != null,
          touchCallback: (event, response) {
            if (onCandleTap == null ||
                response == null ||
                response.touchedSpot == null) {
              return;
            }

            final index = response.touchedSpot!.spotIndex;

            if (index < 0 || index >= visibleCandles.length) {
              return;
            }

            onCandleTap!(visibleCandles[index]);
          },
        ),
      ),
    );

    if (!showVolume) {
      return SizedBox(height: height, child: chart);
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(child: chart),
          const SizedBox(height: 8),
          _VolumeSummary(candles: visibleCandles),
        ],
      ),
    );
  }

  static double _gridInterval(double min, double max) {
    final range = max - min;

    if (range <= 1) {
      return 0.1;
    }

    if (range <= 10) {
      return 1;
    }

    if (range <= 100) {
      return 10;
    }

    if (range <= 1000) {
      return 100;
    }

    return range / 5;
  }

  static double _bottomTitleInterval(int count) {
    if (count <= 8) {
      return 1;
    }

    if (count <= 20) {
      return 3;
    }

    if (count <= 50) {
      return 5;
    }

    if (count <= 100) {
      return 10;
    }

    return (count / 8).ceilToDouble();
  }

  static String _formatTime(DateTime time) {
    final local = time.toLocal();

    final hour = local.hour.toString().padLeft(2, '0');

    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

class _VolumeSummary extends StatelessWidget {
  const _VolumeSummary({required this.candles});

  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return const SizedBox.shrink();
    }

    final latest = candles.last;

    final totalVolume = candles.fold<double>(
      0,
      (sum, candle) => sum + candle.volume,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Volume ${_formatVolume(totalVolume)}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          'Last ${_formatVolume(latest.volume)}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  static String _formatVolume(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)}Cr';
    }

    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)}L';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }

    return value.toStringAsFixed(0);
  }
}
