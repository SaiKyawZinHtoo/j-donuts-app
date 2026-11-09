import 'dart:math';

import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import 'package:j_donuts_app/core/result/result.dart';
import 'remote_dtos.dart';

const Duration kRemoteTimeout = Duration(seconds: 5);
const int kRemoteMaxRetries = 2;
const Duration kRemoteRetryBase = Duration(milliseconds: 200);

/// Dio with the app's timeouts and talker logging. Statuses are handled by
/// [RemoteDataSource], so no status code throws.
Dio buildDio(String baseUrl, {Talker? talker}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: kRemoteTimeout,
      receiveTimeout: kRemoteTimeout,
      validateStatus: (_) => true,
    ),
  );
  dio.interceptors.add(TalkerDioLogger(talker: talker ?? Talker()));
  return dio;
}

/// Fetches `/v1/<resource>` envelopes. Never throws; failures are `Result.err`
/// carrying a [SyncFailure] string.
class RemoteDataSource {
  RemoteDataSource(
    this._dio, {
    this._retryBase = kRemoteRetryBase,
    Talker? talker,
  }) : _talker = talker ?? Talker();

  final Dio _dio;
  final Duration _retryBase;
  final Talker _talker;
  final _rng = Random();

  Future<Result<FetchResult<T>>> fetch<T>(
    String resource,
    T? Function(Map<String, dynamic>) parse, {
    String? etag,
  }) async {
    SyncFailure? last;
    for (var attempt = 0; attempt <= kRemoteMaxRetries; attempt++) {
      if (attempt > 0) {
        final backoff = _retryBase * (1 << (attempt - 1));
        await Future<void>.delayed(backoff + Duration(milliseconds: _rng.nextInt(50)));
      }
      try {
        final res = await _dio.get<dynamic>(
          '/v1/$resource',
          options: Options(headers: {'if-none-match': ?etag}),
        );
        final status = res.statusCode ?? 0;
        if (status == 304) return Result.ok(NotModified<T>());
        if (status >= 500) {
          last = SyncFailure(SyncFailureKind.server, '$status');
          continue;
        }
        if (status != 200) return Result.err(SyncFailure(SyncFailureKind.server, '$status').toString());
        return _parse(res, parse);
      } on DioException catch (e) {
        if (e.error is FormatException) {
          return Result.err(const SyncFailure(SyncFailureKind.invalid, 'malformed JSON').toString());
        }
        final timeout = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout;
        last = SyncFailure(timeout ? SyncFailureKind.timeout : SyncFailureKind.network);
      }
    }
    return Result.err(last.toString());
  }

  Result<FetchResult<T>> _parse<T>(Response<dynamic> res, T? Function(Map<String, dynamic>) parse) {
    Result<FetchResult<T>> invalid(String why) =>
        Result.err(SyncFailure(SyncFailureKind.invalid, why).toString());
    final body = res.data;
    if (body is! Map<String, dynamic>) return invalid('body is not a JSON object');
    if (body['error'] != null) return invalid('server reported an error');
    final data = body['data'];
    if (data is! List) return invalid('data is not a list');
    final items = <T>[];
    for (final raw in data) {
      final item = raw is Map<String, dynamic> ? parse(raw) : null;
      if (item == null) {
        _talker.warning('Skipped invalid record: $raw');
      } else {
        items.add(item);
      }
    }
    if (data.isNotEmpty && items.isEmpty) return invalid('every record is invalid');
    return Result.ok(FetchedData<T>(items, res.headers.value('etag')));
  }
}
