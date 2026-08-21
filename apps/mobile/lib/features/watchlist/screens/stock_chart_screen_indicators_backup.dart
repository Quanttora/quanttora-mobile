import 'dart:math' as math;
import 'dart:ui' as ui;

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

  String _timeframe = '3 min';
  String _period = '5D';

  List<Candle> _candles = [];

  bool _loading = true;
  String? _error;

  double? _vwap;

  bool _showVwap = true;
  bool _showEma22 = true;
  bool _showEma33 = true;
  bool _showBollinger = false;
  bool _showSupertrend = false;

  bool _showRsi = false;
  bool _showMacd = false;
  bool _showAdx = false;
  bool _showAtr = false;
  bool _showStochastic = false;
  bool _showVolume = false;

  bool _crosshairEnabled = true;

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _selectedIndex = null;
    });

    try {
      final now = DateTime.now();
      final range = _dateRangeForPeriod(now, _period);
      final interval = _apiInterval(_timeframe);

      final encodedInstrument = Uri.encodeQueryComponent(widget.instrumentKey);

      final path =
          '/broker/candles'
          '?instrumentKey=$encodedInstrument'
          '&interval=$interval'
          '&fromDate=${_formatDate(range.from)}'
          '&toDate=${_formatDate(range.to)}';

      final response = await _api.get(path);

      final rawCandles = response['candles'] as List<dynamic>? ?? [];
      final parsed = <Candle>[];

      for (final raw in rawCandles) {
        if (raw is! Map) {
          continue;
        }

        final time = DateTime.tryParse(raw['timestamp']?.toString() ?? '');

        final open = _toDouble(raw['open']);
        final high = _toDouble(raw['high']);
        final low = _toDouble(raw['low']);
        final close = _toDouble(raw['close']);
        final volume = _toDouble(raw['volume']);

        if (time == null ||
            open == null ||
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

      parsed.sort((a, b) => a.time.compareTo(b.time));

      final candles = _aggregateIfRequired(parsed, _timeframe, interval);

      if (!mounted) {
        return;
      }

      setState(() {
        _candles = candles;
        _vwap = _toDouble(response['vwap']);
        _loading = false;
        _error = null;
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

  List<Candle> _aggregateIfRequired(
    List<Candle> source,
    String timeframe,
    String apiInterval,
  ) {
    final minutes = _timeframeMinutes(timeframe);

    if (minutes <= 1 ||
        apiInterval == '30minute' ||
        apiInterval == '1hour' ||
        apiInterval == 'day' ||
        source.isEmpty) {
      return source;
    }

    final groups = <DateTime, List<Candle>>{};

    for (final candle in source) {
      final local = candle.time.toLocal();
      final bucketMinute = (local.minute ~/ minutes) * minutes;

      final bucket = DateTime(
        local.year,
        local.month,
        local.day,
        local.hour,
        bucketMinute,
      );

      groups.putIfAbsent(bucket, () => <Candle>[]).add(candle);
    }

    final keys = groups.keys.toList()..sort();
    final result = <Candle>[];

    for (final key in keys) {
      final group = groups[key]!;

      if (group.isEmpty) {
        continue;
      }

      group.sort((a, b) => a.time.compareTo(b.time));

      var high = group.first.high;
      var low = group.first.low;
      var volume = 0.0;

      for (final candle in group) {
        high = math.max(high, candle.high);
        low = math.min(low, candle.low);

        if (candle.volume > 0) {
          volume += candle.volume;
        }
      }

      result.add(
        Candle(
          open: group.first.open,
          high: high,
          low: low,
          close: group.last.close,
          volume: volume,
          time: key,
        ),
      );
    }

    return result;
  }

  String _apiInterval(String timeframe) {
    switch (timeframe) {
      case '1 min':
      case '3 min':
      case '5 min':
      case '15 min':
        return '1minute';
      case '30 min':
        return '30minute';
      case '1 hour':
        return '1hour';
      case '1 day':
        return 'day';
      default:
        return '1minute';
    }
  }

  int _timeframeMinutes(String timeframe) {
    switch (timeframe) {
      case '1 min':
        return 1;
      case '3 min':
        return 3;
      case '5 min':
        return 5;
      case '15 min':
        return 15;
      case '30 min':
        return 30;
      case '1 hour':
        return 60;
      default:
        return 1;
    }
  }

  List<String> _availablePeriods() {
    switch (_timeframe) {
      case '1 min':
      case '3 min':
      case '5 min':
      case '15 min':
        return const ['1D', '5D', '1M'];
      case '30 min':
      case '1 hour':
        return const ['1D', '5D', '1M', '3M'];
      case '1 day':
        return const ['1M', '3M', '6M', '1Y'];
      default:
        return const ['1D', '5D', '1M'];
    }
  }

  List<String> _periodsFor(String timeframe) {
    switch (timeframe) {
      case '1 min':
      case '3 min':
      case '5 min':
      case '15 min':
        return const ['1D', '5D', '1M'];
      case '30 min':
      case '1 hour':
        return const ['1D', '5D', '1M', '3M'];
      case '1 day':
        return const ['1M', '3M', '6M', '1Y'];
      default:
        return const ['1D', '5D', '1M'];
    }
  }

  _DateRange _dateRangeForPeriod(DateTime now, String period) {
    switch (period) {
      case '1D':
        return _DateRange(from: now.subtract(const Duration(days: 1)), to: now);
      case '5D':
        return _DateRange(from: now.subtract(const Duration(days: 5)), to: now);
      case '1M':
        return _DateRange(
          from: DateTime(now.year, now.month - 1, now.day),
          to: now,
        );
      case '3M':
        return _DateRange(
          from: DateTime(now.year, now.month - 3, now.day),
          to: now,
        );
      case '6M':
        return _DateRange(
          from: DateTime(now.year, now.month - 6, now.day),
          to: now,
        );
      case '1Y':
        return _DateRange(
          from: DateTime(now.year - 1, now.month, now.day),
          to: now,
        );
      default:
        return _DateRange(from: now.subtract(const Duration(days: 5)), to: now);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final latest = _candles.isNotEmpty ? _candles.last : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.symbol,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadChart,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPriceHeader(latest),
            _buildTimeframeBar(),
            _buildPeriodBar(),
            Expanded(child: _buildChartBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceHeader(Candle? latest) {
    final price = latest?.close;
    final change = latest == null ? null : latest.close - latest.open;

    final changePercent = latest == null || latest.open == 0
        ? null
        : (change! / latest.open) * 100;

    final positive = change != null && change >= 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LTP',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      price == null
                          ? '--'
                          : '\u20B9${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (change != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '${positive ? '+' : ''}'
                          '${change.toStringAsFixed(2)}'
                          '${changePercent == null ? '' : ' (${positive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)'}',
                          style: TextStyle(
                            color: positive
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'VWAP',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _vwap == null ? '--' : '\u20B9${_vwap!.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF6D4AFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeBar() {
    const timeframes = [
      '1 min',
      '3 min',
      '5 min',
      '15 min',
      '30 min',
      '1 hour',
      '1 day',
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final timeframe = timeframes[index];
          final selected = timeframe == _timeframe;

          return ChoiceChip(
            label: Text(_shortTimeframe(timeframe)),
            selected: selected,
            showCheckmark: selected,
            selectedColor: const Color(0xFFE4E9FF),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? const Color(0xFF5B6FEA)
                  : const Color(0xFFD0D5DD),
            ),
            labelStyle: TextStyle(
              color: selected
                  ? const Color(0xFF3949AB)
                  : const Color(0xFF344054),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
            onSelected: (_) {
              if (_timeframe == timeframe) {
                return;
              }

              final periods = _periodsFor(timeframe);

              setState(() {
                _timeframe = timeframe;

                if (!periods.contains(_period)) {
                  _period = periods.first;
                }
              });

              _loadChart();
            },
          );
        },
      ),
    );
  }

  Widget _buildPeriodBar() {
    final periods = _availablePeriods();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 6),
          const Text(
            'History',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            initialValue: _period,
            onSelected: (period) {
              if (_period == period) {
                return;
              }

              setState(() {
                _period = period;
              });

              _loadChart();
            },
            itemBuilder: (context) {
              return periods
                  .map(
                    (period) => PopupMenuItem<String>(
                      value: period,
                      child: Row(
                        children: [
                          if (_period == period)
                            const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Color(0xFF4F46E5),
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(period),
                        ],
                      ),
                    ),
                  )
                  .toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD0D5DD)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _period,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 18),
              FilledButton(onPressed: _loadChart, child: const Text('RETRY')),
            ],
          ),
        ),
      );
    }

    if (_candles.isEmpty) {
      return const Center(
        child: Text(
          'No historical candle data available.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final selected =
        _selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < _candles.length
        ? _candles[_selectedIndex!]
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 2, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildChartToolsBar(),
          if (selected != null) _buildSelectedCandleInfo(selected),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 390,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
                      child: CandlestickChart(
                        _buildChartData(),
                        duration: const Duration(milliseconds: 120),
                        transformationConfig: const FlTransformationConfig(
                          scaleAxis: FlScaleAxis.horizontal,
                          minScale: 1,
                          maxScale: 8,
                          panEnabled: true,
                          scaleEnabled: true,
                          trackpadScrollCausesScale: true,
                        ),
                      ),
                    ),
                  ),
                  if (_showVolume)
                    _buildIndicatorPanel(
                      title: 'Volume',
                      subtitle: 'Trading volume',
                      child: _buildVolumeChart(),
                    ),
                  if (_showRsi)
                    _buildIndicatorPanel(
                      title: 'RSI 14',
                      subtitle: 'Relative Strength Index',
                      child: _buildRsiChart(),
                    ),
                  if (_showMacd)
                    _buildIndicatorPanel(
                      title: 'MACD',
                      subtitle: '12 / 26 / 9',
                      child: _buildMacdChart(),
                    ),
                  if (_showAdx)
                    _buildIndicatorPanel(
                      title: 'ADX',
                      subtitle: 'Average Directional Index 14',
                      child: _buildAdxChart(),
                    ),
                  if (_showAtr)
                    _buildIndicatorPanel(
                      title: 'ATR',
                      subtitle: 'Average True Range 14',
                      child: _buildAtrChart(),
                    ),
                  if (_showStochastic)
                    _buildIndicatorPanel(
                      title: 'Stochastic',
                      subtitle: '%K 14 / %D 3',
                      child: _buildStochasticChart(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToolsBar() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFBFCFE),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          _chartToolButton(
            icon: Icons.auto_graph_rounded,
            label: 'Indicators',
            onTap: _showIndicatorsMenu,
          ),
          const SizedBox(width: 6),
          _chartToolButton(
            icon: Icons.edit_rounded,
            label: 'Tools',
            onTap: _showToolsMenu,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Chart settings',
            onPressed: _showChartSettings,
            icon: const Icon(
              Icons.tune_rounded,
              size: 19,
              color: Color(0xFF475467),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF475467)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIndicatorsMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Indicators',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  subtitle: Text('Select indicators to display'),
                ),
                _indicatorSwitch(
                  'EMA 22',
                  '22-period Exponential Moving Average',
                  Icons.show_chart_rounded,
                  const Color(0xFF2563EB),
                  _showEma22,
                  (value) => setState(() {
                    _showEma22 = value;
                  }),
                ),
                _indicatorSwitch(
                  'EMA 33',
                  '33-period Exponential Moving Average',
                  Icons.show_chart_rounded,
                  const Color(0xFFDC2626),
                  _showEma33,
                  (value) => setState(() {
                    _showEma33 = value;
                  }),
                ),
                _indicatorSwitch(
                  'VWAP',
                  'Volume Weighted Average Price',
                  Icons.trending_up_rounded,
                  const Color(0xFF7C5CFC),
                  _showVwap,
                  (value) => setState(() {
                    _showVwap = value;
                  }),
                ),
                const Divider(height: 8),
                const ListTile(
                  title: Text(
                    'Trend',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _indicatorSwitch(
                  'Bollinger Bands',
                  '20-period bands with 2 standard deviations',
                  Icons.stacked_line_chart_rounded,
                  const Color(0xFF0891B2),
                  _showBollinger,
                  (value) => setState(() {
                    _showBollinger = value;
                  }),
                ),
                _indicatorSwitch(
                  'Supertrend',
                  'ATR based trend indicator',
                  Icons.swap_vert_rounded,
                  const Color(0xFF16A34A),
                  _showSupertrend,
                  (value) => setState(() {
                    _showSupertrend = value;
                  }),
                ),
                const Divider(height: 8),
                const ListTile(
                  title: Text(
                    'Momentum',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _indicatorSwitch(
                  'RSI',
                  'Relative Strength Index 14',
                  Icons.speed_rounded,
                  const Color(0xFF9333EA),
                  _showRsi,
                  (value) => setState(() {
                    _showRsi = value;
                  }),
                ),
                _indicatorSwitch(
                  'MACD',
                  '12 / 26 / 9 Moving Average Convergence Divergence',
                  Icons.multiline_chart_rounded,
                  const Color(0xFFEA580C),
                  _showMacd,
                  (value) => setState(() {
                    _showMacd = value;
                  }),
                ),
                _indicatorSwitch(
                  'Stochastic',
                  '%K 14 / %D 3',
                  Icons.stacked_line_chart,
                  const Color(0xFFDB2777),
                  _showStochastic,
                  (value) => setState(() {
                    _showStochastic = value;
                  }),
                ),
                const Divider(height: 8),
                const ListTile(
                  title: Text(
                    'Strength / Volatility',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _indicatorSwitch(
                  'ADX',
                  'Average Directional Index 14',
                  Icons.insights_rounded,
                  const Color(0xFF0F766E),
                  _showAdx,
                  (value) => setState(() {
                    _showAdx = value;
                  }),
                ),
                _indicatorSwitch(
                  'ATR',
                  'Average True Range 14',
                  Icons.bar_chart_rounded,
                  const Color(0xFFCA8A04),
                  _showAtr,
                  (value) => setState(() {
                    _showAtr = value;
                  }),
                ),
                const Divider(height: 8),
                const ListTile(
                  title: Text(
                    'Volume',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _indicatorSwitch(
                  'Volume',
                  'Trading volume',
                  Icons.bar_chart_rounded,
                  const Color(0xFF475467),
                  _showVolume,
                  (value) => setState(() {
                    _showVolume = value;
                  }),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _indicatorSwitch(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: color),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showToolsMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Chart Tools',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              SwitchListTile(
                title: const Text('Crosshair'),
                subtitle: const Text('Tap a candle to inspect its price'),
                value: _crosshairEnabled,
                onChanged: (value) {
                  setState(() {
                    _crosshairEnabled = value;
                  });
                },
              ),
              const ListTile(
                leading: Icon(Icons.horizontal_rule_rounded),
                title: Text('Drawing tools'),
                subtitle: Text('Trendline and horizontal line tools'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showChartSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Chart Settings',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.candlestick_chart_rounded),
                title: Text('Candlestick'),
                subtitle: Text('Current chart type'),
              ),
              const ListTile(
                leading: Icon(Icons.touch_app_rounded),
                title: Text('Drag / pinch to zoom'),
                subtitle: Text('Use one finger to pan and pinch to zoom'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedCandleInfo(Candle candle) {
    final bullish = candle.close >= candle.open;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              _formatDateTime(candle.time),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 14),
            _infoItem('O', candle.open, bullish),
            _infoItem('H', candle.high, bullish),
            _infoItem('L', candle.low, bullish),
            _infoItem('C', candle.close, bullish),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'V ${_formatVolume(candle.volume)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475467),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, double value, bool bullish) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value.toStringAsFixed(2),
              style: TextStyle(
                color: bullish
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double?> _calculateEma(int period) {
    final result = List<double?>.filled(_candles.length, null);

    if (_candles.length < period) {
      return result;
    }

    var ema = 0.0;

    for (var i = 0; i < period; i++) {
      ema += _candles[i].close;
    }

    ema /= period;
    result[period - 1] = ema;

    final multiplier = 2.0 / (period + 1);

    for (var i = period; i < _candles.length; i++) {
      ema = ((_candles[i].close - ema) * multiplier) + ema;
      result[i] = ema;
    }

    return result;
  }

  List<double?> _calculateSma(int period) {
    final result = List<double?>.filled(_candles.length, null);

    if (_candles.length < period) {
      return result;
    }

    var sum = 0.0;

    for (var i = 0; i < _candles.length; i++) {
      sum += _candles[i].close;

      if (i >= period) {
        sum -= _candles[i - period].close;
      }

      if (i >= period - 1) {
        result[i] = sum / period;
      }
    }

    return result;
  }

  List<_BollingerPoint> _calculateBollinger() {
    final result = <_BollingerPoint>[];

    if (_candles.length < 20) {
      return result;
    }

    for (var i = 19; i < _candles.length; i++) {
      var sum = 0.0;

      for (var j = i - 19; j <= i; j++) {
        sum += _candles[j].close;
      }

      final mean = sum / 20;
      var variance = 0.0;

      for (var j = i - 19; j <= i; j++) {
        final difference = _candles[j].close - mean;
        variance += difference * difference;
      }

      final deviation = math.sqrt(variance / 20);

      result.add(
        _BollingerPoint(
          index: i,
          middle: mean,
          upper: mean + (2 * deviation),
          lower: mean - (2 * deviation),
        ),
      );
    }

    return result;
  }

  List<double?> _calculateRsi(int period) {
    final result = List<double?>.filled(_candles.length, null);

    if (_candles.length <= period) {
      return result;
    }

    var gains = 0.0;
    var losses = 0.0;

    for (var i = 1; i <= period; i++) {
      final change = _candles[i].close - _candles[i - 1].close;

      if (change >= 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }

    var averageGain = gains / period;
    var averageLoss = losses / period;

    result[period] = _rsiValue(averageGain, averageLoss);

    for (var i = period + 1; i < _candles.length; i++) {
      final change = _candles[i].close - _candles[i - 1].close;

      final gain = change > 0 ? change : 0.0;
      final loss = change < 0 ? change.abs() : 0.0;

      averageGain = ((averageGain * (period - 1)) + gain) / period;

      averageLoss = ((averageLoss * (period - 1)) + loss) / period;

      result[i] = _rsiValue(averageGain, averageLoss);
    }

    return result;
  }

  double _rsiValue(double averageGain, double averageLoss) {
    if (averageLoss == 0) {
      return averageGain == 0 ? 50 : 100;
    }

    final rs = averageGain / averageLoss;
    return 100 - (100 / (1 + rs));
  }

  List<_MacdPoint> _calculateMacd() {
    final ema12 = _calculateEma(12);
    final ema26 = _calculateEma(26);

    final macd = List<double?>.filled(_candles.length, null);

    for (var i = 0; i < _candles.length; i++) {
      if (ema12[i] != null && ema26[i] != null) {
        macd[i] = ema12[i]! - ema26[i]!;
      }
    }

    final signal = List<double?>.filled(_candles.length, null);

    final values = <double>[];
    final indices = <int>[];

    for (var i = 0; i < macd.length; i++) {
      if (macd[i] != null) {
        values.add(macd[i]!);
        indices.add(i);
      }
    }

    if (values.length >= 9) {
      var ema = 0.0;

      for (var i = 0; i < 9; i++) {
        ema += values[i];
      }

      ema /= 9;
      signal[indices[8]] = ema;

      final multiplier = 2.0 / 10.0;

      for (var i = 9; i < values.length; i++) {
        ema = ((values[i] - ema) * multiplier) + ema;
        signal[indices[i]] = ema;
      }
    }

    final result = <_MacdPoint>[];

    for (var i = 0; i < _candles.length; i++) {
      if (macd[i] != null) {
        result.add(_MacdPoint(index: i, macd: macd[i]!, signal: signal[i]));
      }
    }

    return result;
  }

  List<_AdxPoint> _calculateAdx() {
    final result = <_AdxPoint>[];

    if (_candles.length < 28) {
      return result;
    }

    final tr = List<double>.filled(_candles.length, 0);

    final plusDm = List<double>.filled(_candles.length, 0);

    final minusDm = List<double>.filled(_candles.length, 0);

    for (var i = 1; i < _candles.length; i++) {
      final upMove = _candles[i].high - _candles[i - 1].high;

      final downMove = _candles[i - 1].low - _candles[i].low;

      plusDm[i] = upMove > downMove && upMove > 0 ? upMove : 0;

      minusDm[i] = downMove > upMove && downMove > 0 ? downMove : 0;

      final highLow = _candles[i].high - _candles[i].low;

      final highClose = (_candles[i].high - _candles[i - 1].close).abs();

      final lowClose = (_candles[i].low - _candles[i - 1].close).abs();

      tr[i] = math.max(highLow, math.max(highClose, lowClose));
    }

    const period = 14;

    var atr = 0.0;
    var plus = 0.0;
    var minus = 0.0;

    for (var i = 1; i <= period; i++) {
      atr += tr[i];
      plus += plusDm[i];
      minus += minusDm[i];
    }

    atr /= period;
    plus /= period;
    minus /= period;

    final dx = <int, double>{};

    for (var i = period; i < _candles.length; i++) {
      if (i > period) {
        atr = ((atr * (period - 1)) + tr[i]) / period;

        plus = ((plus * (period - 1)) + plusDm[i]) / period;

        minus = ((minus * (period - 1)) + minusDm[i]) / period;
      }

      final plusDi = atr == 0 ? 0 : (100 * plus / atr);

      final minusDi = atr == 0 ? 0 : (100 * minus / atr);

      final denominator = plusDi + minusDi;

      final value = denominator == 0
          ? 0.0
          : 100.0 * (plusDi - minusDi).abs() / denominator;

      dx[i] = value;
    }

    if (dx.length < period) {
      return result;
    }

    final ordered = dx.entries.toList();

    var adx = 0.0;

    for (var i = 0; i < period; i++) {
      adx += ordered[i].value;
    }

    adx /= period;

    result.add(_AdxPoint(index: ordered[period - 1].key, value: adx));

    for (var i = period; i < ordered.length; i++) {
      adx = ((adx * (period - 1)) + ordered[i].value) / period;

      result.add(_AdxPoint(index: ordered[i].key, value: adx));
    }

    return result;
  }

  List<double?> _calculateAtr(int period) {
    final result = List<double?>.filled(_candles.length, null);

    if (_candles.length <= period) {
      return result;
    }

    final tr = List<double>.filled(_candles.length, 0);

    for (var i = 1; i < _candles.length; i++) {
      final highLow = _candles[i].high - _candles[i].low;

      final highClose = (_candles[i].high - _candles[i - 1].close).abs();

      final lowClose = (_candles[i].low - _candles[i - 1].close).abs();

      tr[i] = math.max(highLow, math.max(highClose, lowClose));
    }

    var atr = 0.0;

    for (var i = 1; i <= period; i++) {
      atr += tr[i];
    }

    atr /= period;
    result[period] = atr;

    for (var i = period + 1; i < _candles.length; i++) {
      atr = ((atr * (period - 1)) + tr[i]) / period;

      result[i] = atr;
    }

    return result;
  }

  List<_StochasticPoint> _calculateStochastic() {
    final result = <_StochasticPoint>[];

    const period = 14;
    const smooth = 3;

    if (_candles.length < period) {
      return result;
    }

    final kValues = <double>[];

    for (var i = period - 1; i < _candles.length; i++) {
      var highest = _candles[i].high;
      var lowest = _candles[i].low;

      for (var j = i - period + 1; j <= i; j++) {
        highest = math.max(highest, _candles[j].high);
        lowest = math.min(lowest, _candles[j].low);
      }

      final range = highest - lowest;

      final k = range == 0 ? 50.0 : 100 * (_candles[i].close - lowest) / range;

      kValues.add(k);

      double? d;

      if (kValues.length >= smooth) {
        var sum = 0.0;

        for (var x = kValues.length - smooth; x < kValues.length; x++) {
          sum += kValues[x];
        }

        d = sum / smooth;
      }

      result.add(_StochasticPoint(index: i, k: k, d: d));
    }

    return result;
  }

  List<double> _calculateSupertrend() {
    if (_candles.isEmpty) {
      return [];
    }

    const period = 10;
    const multiplier = 3.0;

    final atr = _calculateAtr(period);
    final result = List<double>.filled(_candles.length, 0);

    var direction = 1;

    for (var i = 0; i < _candles.length; i++) {
      if (atr[i] == null) {
        result[i] = _candles[i].close;
        continue;
      }

      final hl2 = (_candles[i].high + _candles[i].low) / 2;

      final upper = hl2 + (multiplier * atr[i]!);

      final lower = hl2 - (multiplier * atr[i]!);

      if (i > 0) {
        if (_candles[i].close > upper) {
          direction = 1;
        } else if (_candles[i].close < lower) {
          direction = -1;
        }
      }

      result[i] = direction > 0 ? lower : upper;
    }

    return result;
  }

  CandlestickChartData _buildChartData() {
    final spots = List.generate(_candles.length, (index) {
      final candle = _candles[index];

      return CandlestickSpot(
        x: index.toDouble(),
        open: candle.open,
        high: candle.high,
        low: candle.low,
        close: candle.close,
      );
    });

    final ema22 = _calculateEma(22);
    final ema33 = _calculateEma(33);
    final bollinger = _calculateBollinger();
    final supertrend = _calculateSupertrend();

    final prices = <double>[
      ..._candles.map((candle) => candle.high),
      ..._candles.map((candle) => candle.low),
    ];

    if (_showEma22) {
      prices.addAll(ema22.whereType<double>());
    }

    if (_showEma33) {
      prices.addAll(ema33.whereType<double>());
    }

    if (_showBollinger) {
      for (final point in bollinger) {
        prices.add(point.upper);
        prices.add(point.lower);
      }
    }

    if (_showSupertrend) {
      prices.addAll(supertrend);
    }

    if (_showVwap && _vwap != null) {
      prices.add(_vwap!);
    }

    var minPrice = prices.reduce((a, b) => a < b ? a : b);

    var maxPrice = prices.reduce((a, b) => a > b ? a : b);

    if (minPrice == maxPrice) {
      minPrice -= 1;
      maxPrice += 1;
    }

    final range = maxPrice - minPrice;
    final padding = range * 0.06;

    minPrice -= padding;
    maxPrice += padding;

    return CandlestickChartData(
      minX: 0,
      maxX: _candles.length <= 1 ? 1 : (_candles.length - 1).toDouble(),
      minY: minPrice,
      maxY: maxPrice,
      candlestickSpots: spots,
      backgroundColor: Colors.white,
      candlestickPainter: _QuanttoraCandlestickPainter(
        ema22: ema22,
        ema33: ema33,
        showEma22: _showEma22,
        showEma33: _showEma33,
        showVwap: _showVwap,
        vwap: _vwap,
        bollinger: bollinger,
        showBollinger: _showBollinger,
        supertrend: supertrend,
        showSupertrend: _showSupertrend,
        selectedIndex: _selectedIndex,
        selectedClose:
            _selectedIndex != null &&
                _selectedIndex! >= 0 &&
                _selectedIndex! < _candles.length
            ? _candles[_selectedIndex!].close
            : null,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        verticalInterval: _verticalGridInterval(_candles.length),
        horizontalInterval: _horizontalGridInterval(range),
        getDrawingHorizontalLine: (_) {
          return FlLine(
            color: const Color(0xFFDDE3EA).withValues(alpha: 0.72),
            strokeWidth: 0.8,
            dashArray: const [5, 5],
          );
        },
        getDrawingVerticalLine: (_) {
          return FlLine(
            color: const Color(0xFFDDE3EA).withValues(alpha: 0.65),
            strokeWidth: 0.8,
            dashArray: const [5, 5],
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 64,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  _formatPriceScale(value),
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            interval: _bottomTitleInterval(_candles.length),
            getTitlesWidget: (value, meta) {
              final index = value.round();

              if (index < 0 || index >= _candles.length) {
                return const SizedBox.shrink();
              }

              final time = _candles[index].time.toLocal();

              return Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  _formatXAxisTime(time, index),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      candlestickTouchData: CandlestickTouchData(
        enabled: _crosshairEnabled,
        handleBuiltInTouches: false,
        touchSpotThreshold: 18,
        touchCallback: (event, response) {
          final touched = response?.touchedSpot;

          if (touched == null) {
            return;
          }

          final index = touched.spotIndex;

          if (index < 0 || index >= _candles.length || !mounted) {
            return;
          }

          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildIndicatorPanel({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 2),
      padding: const EdgeInsets.only(top: 7, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF344054),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF98A2B3)),
                ),
              ],
            ),
          ),
          SizedBox(height: 145, child: child),
        ],
      ),
    );
  }

  Widget _buildRsiChart() {
    final values = _calculateRsi(14);

    return _buildSimpleLineChart(
      values
          .asMap()
          .entries
          .where((entry) => entry.value != null)
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value!))
          .toList(),
      minY: 0,
      maxY: 100,
      lineColor: const Color(0xFF9333EA),
      horizontalLines: const [30, 50, 70],
    );
  }

  Widget _buildMacdChart() {
    final values = _calculateMacd();

    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final macdSpots = values
        .map((point) => FlSpot(point.index.toDouble(), point.macd))
        .toList();

    final signalSpots = values
        .where((point) => point.signal != null)
        .map((point) => FlSpot(point.index.toDouble(), point.signal!))
        .toList();

    final all = [
      ...macdSpots.map((spot) => spot.y),
      ...signalSpots.map((spot) => spot.y),
      0.0,
    ];

    var minY = all.reduce(math.min).toDouble();
    var maxY = all.reduce(math.max).toDouble();

    final range = math.max(maxY - minY, 0.01);

    minY -= range * 0.15;
    maxY += range * 0.15;

    return _buildMultiLineChart(
      [
        _LineSeries(macdSpots, const Color(0xFFEA580C), 1.8),
        _LineSeries(signalSpots, const Color(0xFF2563EB), 1.5),
      ],
      minY: minY,
      maxY: maxY,
      horizontalLines: const [0],
    );
  }

  Widget _buildAdxChart() {
    final values = _calculateAdx();

    return _buildSimpleLineChart(
      values
          .map((point) => FlSpot(point.index.toDouble(), point.value))
          .toList(),
      minY: 0,
      maxY: 100,
      lineColor: const Color(0xFF0F766E),
      horizontalLines: const [20, 25],
    );
  }

  Widget _buildAtrChart() {
    final values = _calculateAtr(14);

    return _buildSimpleLineChart(
      values
          .asMap()
          .entries
          .where((entry) => entry.value != null)
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value!))
          .toList(),
      lineColor: const Color(0xFFCA8A04),
    );
  }

  Widget _buildStochasticChart() {
    final values = _calculateStochastic();

    final kSpots = values
        .map((point) => FlSpot(point.index.toDouble(), point.k))
        .toList();

    final dSpots = values
        .where((point) => point.d != null)
        .map((point) => FlSpot(point.index.toDouble(), point.d!))
        .toList();

    return _buildMultiLineChart(
      [
        _LineSeries(kSpots, const Color(0xFFDB2777), 1.8),
        _LineSeries(dSpots, const Color(0xFF7C3AED), 1.5),
      ],
      minY: 0,
      maxY: 100,
      horizontalLines: const [20, 50, 80],
    );
  }

  Widget _buildVolumeChart() {
    final spots = _candles
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.volume))
        .toList();

    final maxVolume = spots.isEmpty
        ? 1.0
        : spots.map((spot) => spot.y).reduce(math.max);

    return _buildBarChart(spots, maxY: maxVolume <= 0 ? 1 : maxVolume * 1.1);
  }

  Widget _buildSimpleLineChart(
    List<FlSpot> spots, {
    double? minY,
    double? maxY,
    required Color lineColor,
    List<double> horizontalLines = const [],
  }) {
    if (spots.isEmpty) {
      return const Center(
        child: Text(
          'Not enough data',
          style: TextStyle(fontSize: 10, color: Color(0xFF98A2B3)),
        ),
      );
    }

    final values = spots.map((spot) => spot.y).toList();

    var actualMin = values.reduce(math.min);
    var actualMax = values.reduce(math.max);

    final range = math.max(actualMax - actualMin, 0.01);

    minY ??= actualMin - (range * 0.15);
    maxY ??= actualMax + (range * 0.15);

    return _buildMultiLineChart(
      [_LineSeries(spots, lineColor, 1.8)],
      minY: minY,
      maxY: maxY,
      horizontalLines: horizontalLines,
    );
  }

  Widget _buildMultiLineChart(
    List<_LineSeries> series, {
    required double minY,
    required double maxY,
    List<double> horizontalLines = const [],
  }) {
    final maxX = _candles.length <= 1 ? 1.0 : (_candles.length - 1).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _indicatorHorizontalInterval(maxY - minY),
          getDrawingHorizontalLine: (_) {
            return FlLine(
              color: const Color(0xFFDDE3EA).withValues(alpha: 0.65),
              strokeWidth: 0.7,
              dashArray: const [4, 4],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: horizontalLines
              .map(
                (value) => HorizontalLine(
                  y: value,
                  color: const Color(0xFF98A2B3).withValues(alpha: 0.5),
                  strokeWidth: 0.8,
                  dashArray: const [4, 4],
                ),
              )
              .toList(),
        ),
        lineBarsData: series
            .map(
              (item) => LineChartBarData(
                spots: item.spots,
                isCurved: false,
                color: item.color,
                barWidth: item.width,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBarChart(List<FlSpot> spots, {required double maxY}) {
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) {
            return FlLine(
              color: const Color(0xFFDDE3EA).withValues(alpha: 0.65),
              strokeWidth: 0.7,
              dashArray: const [4, 4],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: spots
            .map(
              (spot) => BarChartGroupData(
                x: spot.x.toInt(),
                barRods: [
                  BarChartRodData(
                    toY: spot.y,
                    width: 3,
                    color: const Color(0xFF94A3B8),
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  double _indicatorHorizontalInterval(double range) {
    if (range <= 2) {
      return 0.25;
    }

    if (range <= 10) {
      return 1;
    }

    if (range <= 50) {
      return 10;
    }

    return range / 4;
  }

  String _shortTimeframe(String timeframe) {
    switch (timeframe) {
      case '1 min':
        return '1m';
      case '3 min':
        return '3m';
      case '5 min':
        return '5m';
      case '15 min':
        return '15m';
      case '30 min':
        return '30m';
      case '1 hour':
        return '1H';
      case '1 day':
        return '1D';
      default:
        return timeframe;
    }
  }

  double _verticalGridInterval(int count) {
    if (count <= 30) {
      return 1;
    }

    if (count <= 100) {
      return 5;
    }

    if (count <= 250) {
      return 10;
    }

    return 20;
  }

  double _horizontalGridInterval(double range) {
    if (range <= 2) {
      return 0.25;
    }

    if (range <= 10) {
      return 1;
    }

    if (range <= 50) {
      return 5;
    }

    if (range <= 200) {
      return 10;
    }

    if (range <= 500) {
      return 25;
    }

    return 50;
  }

  double _bottomTitleInterval(int count) {
    if (count <= 10) {
      return 1;
    }

    if (count <= 30) {
      return 3;
    }

    if (count <= 80) {
      return 8;
    }

    if (count <= 160) {
      return 16;
    }

    return (count / 8).ceilToDouble();
  }

  String _formatXAxisTime(DateTime time, int index) {
    final previous = index > 0 ? _candles[index - 1].time.toLocal() : null;

    final dayChanged =
        previous == null ||
        previous.day != time.day ||
        previous.month != time.month;

    final hour = time.hour.toString().padLeft(2, '0');

    final minute = time.minute.toString().padLeft(2, '0');

    if (dayChanged) {
      return '${time.day.toString().padLeft(2, '0')} '
          '${_monthName(time.month)}\n'
          '$hour:$minute';
    }

    return '$hour:$minute';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _formatPriceScale(double value) {
    if (value >= 1000) {
      return value.toStringAsFixed(0);
    }

    if (value >= 100) {
      return value.toStringAsFixed(1);
    }

    return value.toStringAsFixed(2);
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');

    final month = value.month.toString().padLeft(2, '0');

    final year = value.year.toString();

    final hour = value.hour.toString().padLeft(2, '0');

    final minute = value.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _formatVolume(double value) {
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

class _QuanttoraCandlestickPainter extends FlCandlestickPainter {
  _QuanttoraCandlestickPainter({
    required this.ema22,
    required this.ema33,
    required this.showEma22,
    required this.showEma33,
    required this.showVwap,
    required this.vwap,
    required this.bollinger,
    required this.showBollinger,
    required this.supertrend,
    required this.showSupertrend,
    required this.selectedIndex,
    required this.selectedClose,
  });

  final List<double?> ema22;
  final List<double?> ema33;

  final bool showEma22;
  final bool showEma33;
  final bool showVwap;
  final double? vwap;

  final List<_BollingerPoint> bollinger;
  final bool showBollinger;

  final List<double> supertrend;
  final bool showSupertrend;

  final int? selectedIndex;
  final double? selectedClose;

  @override
  List<Object?> get props => [
    ema22,
    ema33,
    showEma22,
    showEma33,
    showVwap,
    vwap,
    bollinger,
    showBollinger,
    supertrend,
    showSupertrend,
    selectedIndex,
    selectedClose,
  ];

  @override
  void paint(
    ui.Canvas canvas,
    ValueInCanvasProvider xInCanvasProvider,
    ValueInCanvasProvider yInCanvasProvider,
    CandlestickSpot spot,
    int spotIndex,
  ) {
    final bullish = spot.close >= spot.open;

    final bodyColor = bullish
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    final x = xInCanvasProvider(spot.x);

    final highY = yInCanvasProvider(spot.high);
    final lowY = yInCanvasProvider(spot.low);
    final openY = yInCanvasProvider(spot.open);
    final closeY = yInCanvasProvider(spot.close);

    final wickPaint = ui.Paint()
      ..color = bodyColor
      ..strokeWidth = 1.1
      ..style = ui.PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawLine(ui.Offset(x, highY), ui.Offset(x, lowY), wickPaint);

    final bodyTop = math.min(openY, closeY);

    final bodyBottom = math.max(openY, closeY);

    final bodyHeight = (bodyBottom - bodyTop).abs();

    final bodyRect = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTRB(
        x - 4,
        bodyTop,
        x + 4,
        bodyTop + (bodyHeight < 1.5 ? 1.5 : bodyHeight),
      ),
      const ui.Radius.circular(1.5),
    );

    final bodyPaint = ui.Paint()
      ..color = bodyColor
      ..style = ui.PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawRRect(bodyRect, bodyPaint);

    final strokePaint = ui.Paint()
      ..color = bodyColor
      ..strokeWidth = 0.8
      ..style = ui.PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawRRect(bodyRect, strokePaint);

    if (spotIndex == ema22.length - 1) {
      if (showEma22) {
        _drawSeries(
          canvas,
          xInCanvasProvider,
          yInCanvasProvider,
          ema22,
          const Color(0xFF2563EB),
          2.0,
        );
      }

      if (showEma33) {
        _drawSeries(
          canvas,
          xInCanvasProvider,
          yInCanvasProvider,
          ema33,
          const Color(0xFFDC2626),
          2.0,
        );
      }

      if (showBollinger) {
        _drawBollinger(canvas, xInCanvasProvider, yInCanvasProvider);
      }

      if (showSupertrend && supertrend.length == ema22.length) {
        _drawDoubleSeries(
          canvas,
          xInCanvasProvider,
          yInCanvasProvider,
          supertrend,
          const Color(0xFF16A34A),
          1.8,
        );
      }

      if (showVwap && vwap != null) {
        final firstX = xInCanvasProvider(0);

        final lastX = xInCanvasProvider(
          (ema22.length <= 1 ? 1 : ema22.length - 1).toDouble(),
        );

        final vwapY = yInCanvasProvider(vwap!);

        final vwapPaint = ui.Paint()
          ..color = const Color(0xFF7C5CFC).withValues(alpha: 0.82)
          ..strokeWidth = 1.6
          ..style = ui.PaintingStyle.stroke
          ..isAntiAlias = true;

        _drawDashedLine(
          canvas,
          ui.Offset(firstX, vwapY),
          ui.Offset(lastX, vwapY),
          vwapPaint,
        );
      }

      if (selectedIndex != null &&
          selectedIndex! >= 0 &&
          selectedIndex! < ema22.length &&
          selectedClose != null) {
        final selectedX = xInCanvasProvider(selectedIndex!.toDouble());

        final selectedY = yInCanvasProvider(selectedClose!);

        final crosshairPaint = ui.Paint()
          ..color = const Color(0xFF98A2B3).withValues(alpha: 0.55)
          ..strokeWidth = 1
          ..style = ui.PaintingStyle.stroke
          ..isAntiAlias = true;

        final firstX = xInCanvasProvider(0);

        final lastX = xInCanvasProvider(
          (ema22.length <= 1 ? 1 : ema22.length - 1).toDouble(),
        );

        final clipBounds = canvas.getLocalClipBounds();

        _drawDashedLine(
          canvas,
          ui.Offset(selectedX, clipBounds.top),
          ui.Offset(selectedX, clipBounds.bottom),
          crosshairPaint,
        );

        _drawDashedLine(
          canvas,
          ui.Offset(firstX, selectedY),
          ui.Offset(lastX, selectedY),
          crosshairPaint,
        );
      }
    }
  }

  void _drawSeries(
    ui.Canvas canvas,
    ValueInCanvasProvider xProvider,
    ValueInCanvasProvider yProvider,
    List<double?> values,
    Color color,
    double strokeWidth,
  ) {
    final paint = ui.Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..isAntiAlias = true;

    for (var i = 1; i < values.length; i++) {
      final previous = values[i - 1];
      final current = values[i];

      if (previous == null || current == null) {
        continue;
      }

      canvas.drawLine(
        ui.Offset(xProvider((i - 1).toDouble()), yProvider(previous)),
        ui.Offset(xProvider(i.toDouble()), yProvider(current)),
        paint,
      );
    }
  }

  void _drawDoubleSeries(
    ui.Canvas canvas,
    ValueInCanvasProvider xProvider,
    ValueInCanvasProvider yProvider,
    List<double> values,
    Color color,
    double strokeWidth,
  ) {
    final paint = ui.Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..isAntiAlias = true;

    for (var i = 1; i < values.length; i++) {
      canvas.drawLine(
        ui.Offset(xProvider((i - 1).toDouble()), yProvider(values[i - 1])),
        ui.Offset(xProvider(i.toDouble()), yProvider(values[i])),
        paint,
      );
    }
  }

  void _drawBollinger(
    ui.Canvas canvas,
    ValueInCanvasProvider xProvider,
    ValueInCanvasProvider yProvider,
  ) {
    if (bollinger.isEmpty) {
      return;
    }

    final upper = ui.Paint()
      ..color = const Color(0xFF0891B2).withValues(alpha: 0.7)
      ..strokeWidth = 1.1
      ..style = ui.PaintingStyle.stroke
      ..isAntiAlias = true;

    final lower = ui.Paint()
      ..color = const Color(0xFF0891B2).withValues(alpha: 0.7)
      ..strokeWidth = 1.1
      ..style = ui.PaintingStyle.stroke
      ..isAntiAlias = true;

    final middle = ui.Paint()
      ..color = const Color(0xFF0891B2).withValues(alpha: 0.35)
      ..strokeWidth = 0.9
      ..style = ui.PaintingStyle.stroke
      ..isAntiAlias = true;

    for (var i = 1; i < bollinger.length; i++) {
      final previous = bollinger[i - 1];
      final current = bollinger[i];

      canvas.drawLine(
        ui.Offset(
          xProvider(previous.index.toDouble()),
          yProvider(previous.upper),
        ),
        ui.Offset(
          xProvider(current.index.toDouble()),
          yProvider(current.upper),
        ),
        upper,
      );

      canvas.drawLine(
        ui.Offset(
          xProvider(previous.index.toDouble()),
          yProvider(previous.middle),
        ),
        ui.Offset(
          xProvider(current.index.toDouble()),
          yProvider(current.middle),
        ),
        middle,
      );

      canvas.drawLine(
        ui.Offset(
          xProvider(previous.index.toDouble()),
          yProvider(previous.lower),
        ),
        ui.Offset(
          xProvider(current.index.toDouble()),
          yProvider(current.lower),
        ),
        lower,
      );
    }
  }

  void _drawDashedLine(
    ui.Canvas canvas,
    ui.Offset start,
    ui.Offset end,
    ui.Paint paint,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    final distance = math.sqrt((dx * dx) + (dy * dy));

    if (distance <= 0) {
      return;
    }

    const dashLength = 6.0;
    const gapLength = 5.0;

    final ux = dx / distance;
    final uy = dy / distance;

    var position = 0.0;

    while (position < distance) {
      final dashEnd = math.min(position + dashLength, distance);

      canvas.drawLine(
        ui.Offset(start.dx + (ux * position), start.dy + (uy * position)),
        ui.Offset(start.dx + (ux * dashEnd), start.dy + (uy * dashEnd)),
        paint,
      );

      position += dashLength + gapLength;
    }
  }

  @override
  Color getMainColor({required CandlestickSpot spot, required int spotIndex}) {
    return spot.close >= spot.open
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);
  }

  @override
  FlCandlestickPainter lerp(
    FlCandlestickPainter a,
    FlCandlestickPainter b,
    double t,
  ) {
    if (b is _QuanttoraCandlestickPainter) {
      return b;
    }

    return this;
  }
}

class _LineSeries {
  const _LineSeries(this.spots, this.color, this.width);

  final List<FlSpot> spots;
  final Color color;
  final double width;
}

class _BollingerPoint {
  const _BollingerPoint({
    required this.index,
    required this.middle,
    required this.upper,
    required this.lower,
  });

  final int index;
  final double middle;
  final double upper;
  final double lower;
}

class _MacdPoint {
  const _MacdPoint({
    required this.index,
    required this.macd,
    required this.signal,
  });

  final int index;
  final double macd;
  final double? signal;
}

class _AdxPoint {
  const _AdxPoint({required this.index, required this.value});

  final int index;
  final double value;
}

class _StochasticPoint {
  const _StochasticPoint({
    required this.index,
    required this.k,
    required this.d,
  });

  final int index;
  final double k;
  final double? d;
}

class _DateRange {
  const _DateRange({required this.from, required this.to});

  final DateTime from;
  final DateTime to;
}
