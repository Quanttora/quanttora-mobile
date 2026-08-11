import 'package:backend/generated/market_data_v3.pb.dart';

abstract class BrokerMarketFeedInterface {
  bool get isConnected;

  List<String> get subscriptions;

  Future<void> connect();

  Future<void> disconnect();

  Future<void> subscribe(
    List<String> instruments,
  );

  Future<void> unsubscribe(
    List<String> instruments,
  );

  Future<void> subscribeFull(
    String instrumentKey,
  );

  Future<void> unsubscribeFull(
    String instrumentKey,
  );

  Future<void> subscribeMany(
    List<String> instrumentKeys,
  );

  Future<void> unsubscribeMany(
    List<String> instrumentKeys,
  );

  void listen(
    void Function(FeedResponse response) handler,
  );
}