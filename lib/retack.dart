library retack;

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Configuration class for setting up the RetackClient.
///
/// This holds the environment key [envKey], which is used for authentication
/// and allows you to specify the [baseUrl] and [apiEndpoint] for the API.
class RetackConfig {
  // API authentication key to identify the environment.
  final String envKey;

  // The base URL for the Retack AI API. Defaults to 'api.retack.ai'.
  final String baseUrl;

  // The specific endpoint where error reports will be sent.
  final String apiEndpoint;

  /// Constructs a new RetackConfig instance.
  ///
  /// [envKey] is required for authenticating requests to the API.
  /// Optionally, you can override [baseUrl] and [apiEndpoint].
  RetackConfig(
    this.envKey, {
    this.baseUrl = 'api.retack.ai',
    this.apiEndpoint = '/observe/error-log/',
  });
}

/// Class for providing additional context about the user in error reports.
///
/// Contains information such as [userName] and any other relevant
/// metadata in the [extras] map.
class UserContext {
  // Optional: Username or email to identify the user.
  final String? userName;

  // Optional: Additional metadata about the user's context, such as session info.
  final Map<String, dynamic>? extras;

  /// Constructs a new UserContext instance.
  ///
  /// Both [userName] and [extras] are optional and can provide more context
  /// about the user when reporting an error.
  UserContext({
    this.userName,
    this.extras,
  });

  /// Converts the UserContext to a JSON-serializable map.
  ///
  /// This is used when sending the context information to the API.
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'extras': extras,
    };
  }
}

/// A client for interacting with the Retack AI error reporting service.
///
/// This class is responsible for sending error reports along with optional
/// stack traces and user context to the Retack API.
class RetackClient {
  // The Retack configuration that contains API keys and endpoint details.
  final RetackConfig _retackConfig;

  // A private static instance for implementing the Singleton pattern.
  static RetackClient? _instance;

  /// Private constructor to prevent creating multiple instances.
  ///
  /// This is used internally by the factory constructor.
  RetackClient._(this._retackConfig);

  /// Factory constructor to provide a Singleton instance of RetackClient.
  ///
  /// Ensures that only one instance of the client exists throughout the app's
  /// lifecycle. Takes [retackConfig] as the configuration for the client.
  factory RetackClient(RetackConfig retackConfig) {
    // If _instance is null, create a new one, otherwise return the existing instance.
    _instance ??= RetackClient._(retackConfig);
    return _instance!;
  }

  /// Asynchronously reports an error to the Retack AI API.
  ///
  /// [error] is the description of the error.
  /// [stackTrace] contains the stack trace associated with the error.
  /// Optionally, [userContext] can be provided to send more information
  /// about the user affected by the error.
  ///
  /// Returns `true` if the error report was successfully sent, otherwise `false`.
  Future<bool> reportError(
    String error,
    dynamic stackTrace, {
    UserContext? userContext,
  }) async {
    // Define the headers for the HTTP POST request, including the API key.
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json', // Data format is JSON
      'ENV-KEY': _retackConfig.envKey // API key for authentication
    };

    // Construct the body of the request with error, stack trace, and optional user context.
    var body = <String, dynamic>{
      "title": error, // The error message
      "stack_trace":
          stackTrace.toString(), // The stack trace converted to a string
      "user_context": userContext?.toJson(), // User context, if provided
    };

    // Send an HTTP POST request to the Retack API using the provided configuration.
    final http.Response response = await http.post(
      Uri.https(_retackConfig.baseUrl, _retackConfig.apiEndpoint),
      headers: headers,
      body: jsonEncode(body), // Encode the body to JSON format
    );

    // If the response status is not 200 (OK), log the error to the console.
    if (response.statusCode != 200) {
      print('Unable to report error to Retack AI.');
      print(response.body);
    }

    // Return true if the response status is 200 (OK), otherwise false.
    return response.statusCode == 200;
  }
}
