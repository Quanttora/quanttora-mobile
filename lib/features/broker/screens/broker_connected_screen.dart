import 'package:flutter/material.dart';

import 'broker_dashboard_screen.dart';

class BrokerConnectedScreen extends StatelessWidget {
  final String broker;
  final String name;
  final String email;
  final String userId;

  final double availableMargin;
  final double usedMargin;

  const BrokerConnectedScreen({
    super.key,
    required this.broker,
    required this.name,
    required this.email,
    required this.userId,
    required this.availableMargin,
    required this.usedMargin,
  });

  @override
  Widget build(BuildContext context) {
    final totalMargin = availableMargin + usedMargin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broker Connected'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Dashboard refresh will be connected in the next step.
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ----------------------------------------------------------
              // CONNECTION HEADER
              // ----------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF16A34A),
                      Color(0xFF22C55E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Broker Connected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      broker.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // USER INFORMATION
              // ----------------------------------------------------------
              _SectionCard(
                title: 'Account Information',
                icon: Icons.person_outline,
                children: [
                  _InfoTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Broker',
                    value: broker,
                  ),
                  _InfoTile(
                    icon: Icons.person_outline,
                    title: 'Name',
                    value: name,
                  ),
                  _InfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: email,
                  ),
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    title: 'User ID',
                    value: userId.isEmpty ? 'Unavailable' : userId,
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // FUNDS SUMMARY
              // ----------------------------------------------------------
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trading Funds',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 12),

              _TotalFundsCard(
                totalMargin: totalMargin,
                availableMargin: availableMargin,
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _MarginCard(
                      title: 'Available',
                      value: availableMargin,
                      color: Colors.green,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MarginCard(
                      title: 'Used',
                      value: usedMargin,
                      color: Colors.orange,
                      icon: Icons.lock_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // STATUS
              // ----------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connection Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'UPSTOX CONNECTED',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ----------------------------------------------------------
              // CONTINUE
              // ----------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const BrokerDashboardScreen(),
    ),
  );
},
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'Continue to Quanttora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your broker connection is ready for trading data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// TOTAL FUNDS CARD
// ==========================================================================

class _TotalFundsCard extends StatelessWidget {
  final double totalMargin;
  final double availableMargin;

  const _TotalFundsCard({
    required this.totalMargin,
    required this.availableMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined),
              SizedBox(width: 8),
              Text(
                'Total Trading Margin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹ ${totalMargin.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹ ${availableMargin.toStringAsFixed(2)} currently available',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// MARGIN CARD
// ==========================================================================

class _MarginCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final IconData icon;

  const _MarginCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// SECTION CARD
// ==========================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

// ==========================================================================
// INFORMATION TILE
// ==========================================================================

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool showDivider;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}