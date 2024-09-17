A Dart package to report application errors & exceptions to Retack.AI for Flutter and Dart applications.

## What is Retack AI?
Retack AI is a new generation Application error monitoring and tracking platform which not only helps you monitor errors wherever they occur but also has an advanced AI support to instantly fix your code repository. 

Learn more: [Retack.AI](https://retack.ai)

## Getting started

Start by creating an instance of `RetackClient` class by providing your `ENV_KEY`.

```dart
final RetackConfig retackConfig = RetackConfig('YOUR_ENV_KEY');
final RetackClient retackClient = RetackClient(retackConfig);
```

You can now make use of `reportError` function to report errors wherever they occur in your application

You can also pass `UserContext` as additional optional parameter to send further info about current error and affected `User`.

## Usage Example
Here's a sample example for reference:

```dart

final String falseenvKey = 'YOUR_ENV_KEY';
final RetackClient client = RetackClient(RetackConfig(falseenvKey));

try {
    throw const FormatException('Format Exception');
} catch (_, __) {
    final bool resp = await client.reportError(
        _.toString(),
        __,
        userContext: UserContext(userName: 'user@retack.io'),
    );
}
  
```

## Additional information
Retack.AI is powered by [Truenary](https://truenary.com)
