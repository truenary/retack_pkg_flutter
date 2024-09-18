import 'package:test/test.dart';
import 'package:retack/retack.dart';

void main() {
  // Grouping the test case(s) under a descriptive label for better organization
  group('RetackClient Error Reporting', () {
    test('Test Retack AI fails with Invalid Key', () async {
      // Arrange: Set up the RetackClient with a fake/invalid environment key.
      final String falseEnvKey =
          'CMskbtq_xDA46XAkAzQe1JEY12'; // This key is intentionally invalid
      final RetackClient client = RetackClient(RetackConfig(falseEnvKey));

      try {
        // Act: Triggering an error (in this case, a FormatException) to simulate an error scenario
        throw const FormatException('Format Exception');
      } catch (error, stackTrace) {
        // Act: Attempting to report the error to Retack with the invalid key
        final bool resp = await client.reportError(
          error.toString(), // Convert the error to a string
          stackTrace, // Capture the stack trace of the error
          userContext: UserContext(
              userName: 'user@retack.io'), // Providing a mock user context
        );

        // Assert: Since the environment key is invalid, we expect the error report to fail (i.e., resp should be false)
        expect(resp, false);
      }
    });
  });
}
