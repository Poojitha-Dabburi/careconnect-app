library default_connector;

import 'package:firebase_data_connect/firebase_data_connect.dart';

class DefaultConnector {
  static final ConnectorConfig _connectorConfig = ConnectorConfig(
    'us-central1', // Region
    'default',     // Connector name
    'careconnect', // Project name
  );

  static DefaultConnector? _instance;

  final FirebaseDataConnect dataConnect;

  // Private constructor
  DefaultConnector._(this.dataConnect);

  // Singleton instance
  factory DefaultConnector.instance() {
    _instance ??= DefaultConnector._(
      FirebaseDataConnect.instanceFor(
        connectorConfig: _connectorConfig,
      ),
    );
    return _instance!;
  }
}
