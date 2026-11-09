part of '../../home_import.dart';

enum SyncOutcome { updated, notModified }

/// Refreshes the local public data (products, banners, sections, shops) from
/// the server. The UI never reads the server; it re-reads the database.
abstract class SyncRepository {
  /// Concurrent calls share one in-flight run. A failure leaves the database
  /// untouched.
  Future<Result<SyncOutcome>> refresh();

  Future<DateTime?> lastSyncedAt();
}
