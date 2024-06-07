library retack;

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Configuration for the RetackClient.
class RetackConfig {
  final String apiKey;
  final String baseUrl;
  final String apiEndpoint;

  RetackConfig(
    this.apiKey, {
    this.baseUrl = 'api.retack.ai',
    this.apiEndpoint = '/observe/error-log/',
  });
}

/// Additional context about the user.
class UserContext {
  // provide either unique userEmail or userName if available
  final String? userName;
  // any extra meta-data about the user context
  final Map<String, dynamic>? extras;

  UserContext({
    this.userName,
    this.extras,
  });

  // Method to convert UserContext to a JSON-encodable map
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'extras': extras,
    };
  }
}

/// A client for reporting errors to the Retack AI service.
class RetackClient {
  final RetackConfig _retackConfig;
  static RetackClient? _instance;

  /// Private constructor to prevent instantiation from outside.
  RetackClient._(this._retackConfig);

  /// Factory constructor to provide access to the singleton instance.
  factory RetackClient(RetackConfig retackConfig) {
    _instance ??= RetackClient._(retackConfig);
    return _instance!;
  }

  /// Reports an error to the Retack AI service.
  ///
  /// [error] The error message.
  /// [stackTrace] The stack trace of the error.
  /// [userContext] Additional context about the user (optional).
  ///
  /// Returns `true` if the error was successfully reported, `false` otherwise.
  Future<bool> reportError(
    String error,
    dynamic stackTrace, {
    UserContext? userContext,
  }) async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'ENV-KEY': _retackConfig.apiKey
    };
    var body = <String, dynamic>{
      "title": error,
      "stack_trace": stackTrace.toString(),
      "user_context": userContext?.toJson(),
    };

    final http.Response response = await http.post(
      Uri.https(_retackConfig.baseUrl, _retackConfig.apiEndpoint),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      print('Unable to report error to Retack AI.');
      print(response.body);
    }
    return response.statusCode == 200;
  }
}
