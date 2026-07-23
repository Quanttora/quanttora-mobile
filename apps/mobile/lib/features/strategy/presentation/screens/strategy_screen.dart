import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/strategy_list_provider.dart';

class StrategyScreen extends ConsumerWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategies = ref.watch(strategyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Strategies'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(strategyListProvider);
          await ref.read(strategyListProvider.future);
        },
        child: strategies.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (data) {
            if (data.isEmpty) {
              return const Center(
                child: Text(
                  'No Strategies Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final strategy = data[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(strategy.name),
                    subtitle: Text(
                      strategy.description,
                    ),
                    trailing: Icon(
                      strategy.isActive
                          ? Icons.check_circle
                          : Icons.pause_circle,
                      color: strategy.isActive
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create Strategy Screen (Next Step)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}