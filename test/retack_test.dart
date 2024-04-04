import 'package:test/test.dart';

import 'package:retack_pkg/retack.dart';

void main() {
  test('Test Retack AI fails with Invalid Key', () async {
    final String falseApiKey = 'CMskbtq_xDA46XAkAzQe1JEY12';
    final RetackClient client = RetackClient(RetackConfig(falseApiKey));

    try {
      throw const FormatException('Format Exception');
    } catch (_, __) {
      final bool resp = await client.reportError(
        _.toString(),
        __,
        userContext: UserContext(userName: 'user@retack.io'),
      );
      expect(resp, false);
    }
  });
}
