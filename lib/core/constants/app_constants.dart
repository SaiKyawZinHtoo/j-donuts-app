part of '../core_import.dart';

const String kFakeOtpCode = '123456';
const int kMinAgeYears = 13;
const int kOtpResendSeconds = 300;
const int kOtpMaxAttempts = 3;
const Duration kFakeNetworkDelay = Duration(seconds: 1);

/// Base URL of the mock server; empty means local-only (no background sync).
const String kApiBaseUrl = String.fromEnvironment('API_BASE_URL');
