import 'package:backend/interfaces/broker/broker_option_chain_interface.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/upstox_option_chain_service.dart';

class BrokerOptionChainService {
  BrokerOptionChainService._();

  static final BrokerOptionChainService instance =
      BrokerOptionChainService._();

  BrokerOptionChainInterface get current {
    final broker =
        BrokerService.instance.session?.broker;

    switch (broker?.toLowerCase()) {
      case 'upstox':
        return UpstoxOptionChainService.instance;

      default:
        throw UnsupportedError(
          'Option chain is not supported for broker: $broker',
        );
    }
  }

  bool get isSupported {
    final broker =
        BrokerService.instance.session?.broker;

    switch (broker?.toLowerCase()) {
      case 'upstox':
        return true;

      default:
        return false;
    }
  }

  Future<Map<String, dynamic>> getOptionContracts({
    required String instrumentKey,
    String? expiryDate,
  }) {
    final broker =
        BrokerService.instance.session?.broker;

    switch (broker?.toLowerCase()) {
      case 'upstox':
        return UpstoxOptionChainService.instance
            .getOptionContracts(
          instrumentKey: instrumentKey,
          expiryDate: expiryDate,
        );

      default:
        throw UnsupportedError(
          'Option contracts are not supported for broker: $broker',
        );
    }
  }
}